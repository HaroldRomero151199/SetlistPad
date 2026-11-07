import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:setlist_pad/core/providers/providers.dart';
import 'package:setlist_pad/core/services/services.dart';
import 'package:setlist_pad/features/playlists/playlists.dart';
import 'package:setlist_pad/features/songs/songs.dart';

class FakeYouTubeService extends YouTubeService {
  YouTubePlaylistMetadata? playlistToReturn;
  bool shouldThrow = false;

  @override
  Future<YouTubePlaylistMetadata> fetchPlaylistMetadata(String playlistUrl) async {
    if (shouldThrow) {
      throw Exception('Remote playlist unreachable or private');
    }
    if (playlistToReturn != null) {
      return playlistToReturn!;
    }
    return YouTubePlaylistMetadata(
      id: 'pl-mock',
      title: 'Mock Playlist',
      items: const [],
    );
  }
}

class FakeLyricsService extends LyricsService {
  @override
  Future<String?> fetchLyrics({required String title, required String artist}) async {
    if (title.contains('FailLyrics')) {
      throw Exception('Lyrics API timeout');
    }
    return 'Lyrics for $title by $artist';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Box<Playlist> playlistBox;
  late Box<Song> songBox;
  late PlaylistRepository playlistRepo;
  late SongRepository songRepo;
  late FakeYouTubeService fakeYouTubeService;
  late FakeLyricsService fakeLyricsService;
  late ProviderContainer container;
  late PlaylistsNotifier notifier;

  setUp(() async {
    Hive.init('./test_hive_playlists_notifier');
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SongAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PlaylistAdapter());
    }
    playlistBox = await Hive.openBox<Playlist>('test_playlists_box');
    await playlistBox.clear();
    songBox = await Hive.openBox<Song>('test_sync_songs_box');
    await songBox.clear();

    playlistRepo = HivePlaylistRepository(playlistBox: playlistBox);
    songRepo = HiveSongRepository(songBox: songBox);
    fakeYouTubeService = FakeYouTubeService();
    fakeLyricsService = FakeLyricsService();

    container = ProviderContainer(
      overrides: [
        playlistRepositoryProvider.overrideWithValue(playlistRepo),
        songRepositoryProvider.overrideWithValue(songRepo),
        youtubeServiceProvider.overrideWithValue(fakeYouTubeService),
        lyricsServiceProvider.overrideWithValue(fakeLyricsService),
      ],
    );

    notifier = container.read(playlistsNotifierProvider.notifier);
  });

  tearDown(() async {
    container.dispose();
    await playlistBox.close();
    await songBox.close();
    await Hive.deleteBoxFromDisk('test_playlists_box');
    await Hive.deleteBoxFromDisk('test_sync_songs_box');
  });

  group('PlaylistsNotifier Tests', () {
    test('createPlaylist should store a new playlist in Hive and state', () async {
      final playlist = await notifier.createPlaylist(
        name: 'Saturday Gig',
        description: 'Rock songs',
      );

      final list = notifier.state.value ?? [];
      expect(list.length, 1);
      expect(list.first.id, playlist.id);
      expect(list.first.name, 'Saturday Gig');
    });

    test('addSongToPlaylist & removeSongFromPlaylist should update playlist songIds', () async {
      final playlist = await notifier.createPlaylist(
        name: 'Acoustic Set',
      );

      await notifier.addSongToPlaylist(playlist.id, 'song-101');
      var updated = await playlistRepo.getPlaylistById(playlist.id);
      expect(updated?.songIds, ['song-101']);

      await notifier.removeSongFromPlaylist(playlist.id, 'song-101');
      updated = await playlistRepo.getPlaylistById(playlist.id);
      expect(updated?.songIds.isEmpty, isTrue);
    });

    test('removeSongFromAllPlaylists should remove song across playlists and update state', () async {
      final p1 = await notifier.createPlaylist(name: 'Set 1');
      final p2 = await notifier.createPlaylist(name: 'Set 2');

      await notifier.addSongToPlaylist(p1.id, 'song-abc');
      await notifier.addSongToPlaylist(p2.id, 'song-abc');

      await notifier.removeSongFromAllPlaylists('song-abc');

      final updatedP1 = await playlistRepo.getPlaylistById(p1.id);
      final updatedP2 = await playlistRepo.getPlaylistById(p2.id);
      expect(updatedP1?.songIds.contains('song-abc'), isFalse);
      expect(updatedP2?.songIds.contains('song-abc'), isFalse);
    });

    group('syncPlaylist Tests', () {
      test(
        'Scenario 1: Sincronización exitosa con altas y bajas (A, B -> B, C)',
        () async {
          final now = DateTime.now();
          final songA = Song(
            id: 'song-A',
            title: 'Song A',
            artist: 'Artist A',
            youtubeUrl: 'https://www.youtube.com/watch?v=vidA',
            lyrics: 'Lyrics A',
            createdAt: now,
            updatedAt: now,
          );
          final songB = Song(
            id: 'song-B',
            title: 'Song B',
            artist: 'Artist B',
            youtubeUrl: 'https://www.youtube.com/watch?v=vidB',
            lyrics: 'Lyrics B',
            createdAt: now,
            updatedAt: now,
          );
          await songRepo.saveSong(songA);
          await songRepo.saveSong(songB);

          final playlist = await notifier.createPlaylist(
            name: 'Live Gig',
            youtubePlaylistUrl: 'https://www.youtube.com/playlist?list=PL123',
            songIds: ['song-A', 'song-B'],
          );

          // Remote contains [B, C]
          fakeYouTubeService.playlistToReturn = YouTubePlaylistMetadata(
            id: 'PL123',
            title: 'Live Gig Remote',
            items: [
              YouTubePlaylistItem(
                videoId: 'vidB',
                title: 'Song B',
                artist: 'Artist B',
                rawTitle: 'Artist B - Song B',
                url: 'https://www.youtube.com/watch?v=vidB',
              ),
              YouTubePlaylistItem(
                videoId: 'vidC',
                title: 'Song C',
                artist: 'Artist C',
                rawTitle: 'Artist C - Song C',
                url: 'https://www.youtube.com/watch?v=vidC',
              ),
            ],
          );

          final result = await notifier.syncPlaylist(playlist.id);

          expect(result.addedCount, 1);
          expect(result.removedCount, 1);
          expect(result.totalCount, 2);

          final updatedPlaylist = await playlistRepo.getPlaylistById(playlist.id);
          expect(updatedPlaylist, isNotNull);
          expect(updatedPlaylist!.youtubePlaylistUrl, 'https://www.youtube.com/playlist?list=PL123');
          expect(updatedPlaylist.songIds.contains('song-A'), isFalse);
          expect(updatedPlaylist.songIds.contains('song-B'), isTrue);

          // Song C should have been created in SongRepository
          final allSongs = await songRepo.getAllSongs();
          final songC = allSongs.firstWhere((s) => s.title == 'Song C');
          expect(songC.artist, 'Artist C');
          expect(songC.lyrics, 'Lyrics for Song C by Artist C');
          expect(updatedPlaylist.songIds, ['song-B', songC.id]);

          // Song A is still in the catalog
          final foundA = await songRepo.getSongById('song-A');
          expect(foundA, isNotNull);
        },
      );

      test('re-uses existing song from catalog instead of duplicating it', () async {
        final now = DateTime.now();
        final existingC = Song(
          id: 'song-c-existing',
          title: 'Song C',
          artist: 'Artist C',
          youtubeUrl: 'https://www.youtube.com/watch?v=vidC',
          lyrics: 'Pre-existing lyrics',
          createdAt: now,
          updatedAt: now,
        );
        await songRepo.saveSong(existingC);

        final playlist = await notifier.createPlaylist(
          name: 'My Playlist',
          youtubePlaylistUrl: 'https://www.youtube.com/playlist?list=PL456',
          songIds: [],
        );

        fakeYouTubeService.playlistToReturn = YouTubePlaylistMetadata(
          id: 'PL456',
          title: 'Remote',
          items: [
            YouTubePlaylistItem(
              videoId: 'vidC',
              title: 'Song C',
              artist: 'Artist C',
              rawTitle: 'Artist C - Song C',
              url: 'https://www.youtube.com/watch?v=vidC',
            ),
          ],
        );

        final result = await notifier.syncPlaylist(playlist.id);
        expect(result.addedCount, 1);
        expect(result.removedCount, 0);

        final songsInRepo = await songRepo.getAllSongs();
        expect(songsInRepo.length, 1);
        expect(songsInRepo.first.id, 'song-c-existing');

        final updatedPlaylist = await playlistRepo.getPlaylistById(playlist.id);
        expect(updatedPlaylist!.songIds, ['song-c-existing']);
      });

      test('throws FormatException when playlist has no youtubePlaylistUrl', () async {
        final playlist = await notifier.createPlaylist(
          name: 'Manual Playlist',
          songIds: ['song-1'],
        );

        expect(
          () => notifier.syncPlaylist(playlist.id),
          throwsA(isA<FormatException>()),
        );
      });

      test(
        'Scenario 3: Error al consultar el enlace remoto mantiene la lista intacta',
        () async {
          final playlist = await notifier.createPlaylist(
            name: 'Original Playlist',
            youtubePlaylistUrl: 'https://www.youtube.com/playlist?list=PL_FAIL',
            songIds: ['song-1', 'song-2'],
          );

          fakeYouTubeService.shouldThrow = true;

          expect(
            () => notifier.syncPlaylist(playlist.id),
            throwsA(isA<Exception>()),
          );

          final intact = await playlistRepo.getPlaylistById(playlist.id);
          expect(intact!.songIds, ['song-1', 'song-2']);
          expect(intact.name, 'Original Playlist');
        },
      );

      test('handles empty remote playlist by throwing without altering local playlist', () async {
        final playlist = await notifier.createPlaylist(
          name: 'Original Playlist',
          youtubePlaylistUrl: 'https://www.youtube.com/playlist?list=PL_EMPTY',
          songIds: ['song-1', 'song-2'],
        );

        fakeYouTubeService.playlistToReturn = YouTubePlaylistMetadata(
          id: 'PL_EMPTY',
          title: 'Empty',
          items: const [],
        );

        expect(
          () => notifier.syncPlaylist(playlist.id),
          throwsA(isA<Exception>()),
        );

        final intact = await playlistRepo.getPlaylistById(playlist.id);
        expect(intact!.songIds, ['song-1', 'song-2']);
      });

      test('gracefully continues sync if LyricsService throws', () async {
        final playlist = await notifier.createPlaylist(
          name: 'Fail Lyrics Playlist',
          youtubePlaylistUrl: 'https://www.youtube.com/playlist?list=PL_FAIL_LYRICS',
          songIds: [],
        );

        fakeYouTubeService.playlistToReturn = YouTubePlaylistMetadata(
          id: 'PL_FAIL_LYRICS',
          title: 'Fail Lyrics',
          items: [
            YouTubePlaylistItem(
              videoId: 'vidFail',
              title: 'FailLyrics Song',
              artist: 'Artist',
              rawTitle: 'FailLyrics Song',
              url: 'https://www.youtube.com/watch?v=vidFail',
            ),
          ],
        );

        final result = await notifier.syncPlaylist(playlist.id);
        expect(result.addedCount, 1);

        final allSongs = await songRepo.getAllSongs();
        expect(allSongs.first.title, 'FailLyrics Song');
        expect(allSongs.first.lyrics, ''); // empty lyrics fallback
      });
    });
  });
}
