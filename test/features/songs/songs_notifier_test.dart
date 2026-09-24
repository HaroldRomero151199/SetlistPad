import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:setlist_pad/core/providers/providers.dart';
import 'package:setlist_pad/core/services/services.dart';
import 'package:setlist_pad/features/playlists/playlists.dart';
import 'package:setlist_pad/features/songs/songs.dart';

class FakeLyricsService extends LyricsService {
  @override
  Future<String?> fetchLyrics({required String title, required String artist}) async {
    if (title.contains('Yellow')) {
      return 'Look at the stars...';
    }
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Box<Song> songBox;
  late SongRepository repository;
  late YouTubeService youtubeService;
  late LyricsService lyricsService;
  late ProviderContainer container;
  late SongsNotifier notifier;

  setUp(() async {
    Hive.init('./test_hive_songs_notifier');
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SongAdapter());
    }
    songBox = await Hive.openBox<Song>('test_songs_box');
    await songBox.clear();

    repository = HiveSongRepository(songBox: songBox);
    youtubeService = YouTubeService();
    lyricsService = FakeLyricsService();

    container = ProviderContainer(
      overrides: [
        songRepositoryProvider.overrideWithValue(repository),
        youtubeServiceProvider.overrideWithValue(youtubeService),
        lyricsServiceProvider.overrideWithValue(lyricsService),
      ],
    );

    notifier = container.read(songsNotifierProvider.notifier);
  });

  tearDown(() async {
    container.dispose();
    await songBox.clear();
    await songBox.close();
  });

  group('SongsNotifier Tests', () {
    test('addSong should save a new song to repository and update state', () async {
      await notifier.addSong(
        title: 'Yellow',
        artist: 'Coldplay',
        lyrics: 'Look at the stars...',
      );

      final songs = notifier.state.value ?? [];
      expect(songs.length, 1);
      expect(songs.first.title, 'Yellow');
      expect(songs.first.artist, 'Coldplay');
    });

    test('importSongsBatch should save multiple songs and optionally add them to target playlist', () async {
      final fakePlaylistRepo = FakePlaylistRepository();
      fakePlaylistRepo.playlists.add(Playlist(
        id: 'pl-batch',
        name: 'Batch Playlist',
        songIds: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final batchContainer = ProviderContainer(
        overrides: [
          songRepositoryProvider.overrideWithValue(repository),
          playlistRepositoryProvider.overrideWithValue(fakePlaylistRepo),
          youtubeServiceProvider.overrideWithValue(youtubeService),
          lyricsServiceProvider.overrideWithValue(lyricsService),
        ],
      );
      addTearDown(batchContainer.dispose);

      final batchNotifier = batchContainer.read(songsNotifierProvider.notifier);

      final items = [
        YouTubePlaylistItem(
          videoId: 'v1',
          title: 'Yellow',
          artist: 'Coldplay',
          rawTitle: 'Coldplay - Yellow',
          url: 'https://youtube.com/watch?v=v1',
        ),
        YouTubePlaylistItem(
          videoId: 'v2',
          title: 'Creep',
          artist: 'Radiohead',
          rawTitle: 'Radiohead - Creep',
          url: 'https://youtube.com/watch?v=v2',
        ),
      ];

      final progressValues = <int>[];
      final imported = await batchNotifier.importSongsBatch(
        items,
        targetPlaylistId: 'pl-batch',
        onProgress: (cur, tot) => progressValues.add(cur),
      );

      expect(imported.length, 2);
      expect(progressValues, [1, 2]);

      final allSongs = await repository.getAllSongs();
      expect(allSongs.length, 2);

      final updatedPlaylist = await fakePlaylistRepo.getPlaylistById('pl-batch');
      expect(updatedPlaylist?.songIds.length, 2);
    });

    test('fetchAndSaveLyrics should find online lyrics and update song in repo and state', () async {
      final now = DateTime.now();
      final song = Song(
        id: 'coldplay-1',
        title: 'Yellow',
        artist: 'Coldplay',
        lyrics: '',
        createdAt: now,
        updatedAt: now,
      );
      await repository.saveSong(song);
      await notifier.loadSongs();

      final success = await notifier.fetchAndSaveLyrics('coldplay-1');
      expect(success, isTrue);

      final updated = await repository.getSongById('coldplay-1');
      expect(updated?.lyrics, 'Look at the stars...');
    });

    test('updateLyrics should modify song lyrics', () async {
      await notifier.addSong(
        title: 'Fix You',
        artist: 'Coldplay',
        lyrics: 'When you try your best...',
      );

      final songId = notifier.state.value!.first.id;
      await notifier.updateLyrics(songId, 'Updated lyrics content');

      final updatedSong = await repository.getSongById(songId);
      expect(updatedSong?.lyrics, 'Updated lyrics content');
    });

    test('deleteSong should remove song from state and repository', () async {
      await notifier.addSong(
        title: 'Clocks',
        artist: 'Coldplay',
        lyrics: 'Lights go out...',
      );

      final songId = notifier.state.value!.first.id;
      await notifier.deleteSong(songId);

      final songs = notifier.state.value ?? [];
      expect(songs.isEmpty, isTrue);
    });

    test('deleteSong should also remove song from all playlists', () async {
      final fakePlaylistRepo = FakePlaylistRepository();
      fakePlaylistRepo.playlists.add(Playlist(
        id: 'pl-1',
        name: 'My Setlist',
        songIds: ['song-del', 'song-keep'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final testContainer = ProviderContainer(
        overrides: [
          songRepositoryProvider.overrideWithValue(repository),
          playlistRepositoryProvider.overrideWithValue(fakePlaylistRepo),
        ],
      );
      addTearDown(testContainer.dispose);

      final testNotifier = testContainer.read(songsNotifierProvider.notifier);
      await testNotifier.deleteSong('song-del');

      expect(fakePlaylistRepo.playlists.first.songIds, ['song-keep']);
    });
  });
}

class FakePlaylistRepository implements PlaylistRepository {
  final List<Playlist> playlists = [];

  @override
  Future<List<Playlist>> getAllPlaylists() async => playlists;

  @override
  Future<Playlist?> getPlaylistById(String id) async {
    try {
      return playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> savePlaylist(Playlist playlist) async {
    playlists.removeWhere((p) => p.id == playlist.id);
    playlists.add(playlist);
  }

  @override
  Future<void> deletePlaylist(String id) async {
    playlists.removeWhere((p) => p.id == id);
  }

  @override
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final pl = await getPlaylistById(playlistId);
    if (pl != null && !pl.songIds.contains(songId)) {
      await savePlaylist(pl.copyWith(songIds: [...pl.songIds, songId]));
    }
  }

  @override
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final pl = await getPlaylistById(playlistId);
    if (pl != null) {
      final list = List<String>.from(pl.songIds)..remove(songId);
      await savePlaylist(pl.copyWith(songIds: list));
    }
  }

  @override
  Future<void> removeSongFromAllPlaylists(String songId) async {
    for (int i = 0; i < playlists.length; i++) {
      if (playlists[i].songIds.contains(songId)) {
        final list = List<String>.from(playlists[i].songIds)..remove(songId);
        playlists[i] = playlists[i].copyWith(songIds: list);
      }
    }
  }
}
