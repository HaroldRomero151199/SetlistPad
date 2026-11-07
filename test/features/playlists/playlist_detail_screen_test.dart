import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setlist_pad/core/providers/providers.dart';
import 'package:setlist_pad/core/services/services.dart';
import 'package:setlist_pad/features/playlists/playlists.dart';
import 'package:setlist_pad/features/songs/songs.dart';
import 'package:setlist_pad/l10n/app_localizations.dart';

class FakeSongRepository implements SongRepository {
  final List<Song> songs = [];

  @override
  Future<void> deleteSong(String id) async {
    songs.removeWhere((s) => s.id == id);
  }

  @override
  Future<List<Song>> getAllSongs() async => List.unmodifiable(songs);

  @override
  Future<Song?> getSongById(String id) async {
    try {
      return songs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveSong(Song song) async {
    final index = songs.indexWhere((s) => s.id == song.id);
    if (index >= 0) {
      songs[index] = song;
    } else {
      songs.add(song);
    }
  }

  @override
  Future<List<Song>> searchSongs(String query) async {
    final q = query.toLowerCase();
    return songs
        .where((s) =>
            s.title.toLowerCase().contains(q) ||
            s.artist.toLowerCase().contains(q))
        .toList();
  }
}

class FakePlaylistRepository implements PlaylistRepository {
  final List<Playlist> playlists = [];

  @override
  Future<List<Playlist>> getAllPlaylists() async => List.unmodifiable(playlists);

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
    return 'Lyrics for $title by $artist';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeSongRepository fakeSongRepo;
  late FakePlaylistRepository fakePlaylistRepo;
  late FakeYouTubeService fakeYouTubeService;
  late FakeLyricsService fakeLyricsService;

  setUp(() {
    fakeSongRepo = FakeSongRepository();
    fakePlaylistRepo = FakePlaylistRepository();
    fakeYouTubeService = FakeYouTubeService();
    fakeLyricsService = FakeLyricsService();
  });

  Widget buildSubject({
    required Playlist playlist,
    Locale locale = const Locale('es'),
  }) {
    return ProviderScope(
      overrides: [
        songRepositoryProvider.overrideWithValue(fakeSongRepo),
        playlistRepositoryProvider.overrideWithValue(fakePlaylistRepo),
        youtubeServiceProvider.overrideWithValue(fakeYouTubeService),
        lyricsServiceProvider.overrideWithValue(fakeLyricsService),
        playlistsNotifierProvider.overrideWith(
          () => PlaylistsNotifier(
            repository: fakePlaylistRepo,
            songRepository: fakeSongRepo,
            youtubeService: fakeYouTubeService,
            lyricsService: fakeLyricsService,
          ),
        ),
        songsNotifierProvider.overrideWith(
          () => SongsNotifier(
            repository: fakeSongRepo,
            playlistRepository: fakePlaylistRepo,
            youtubeService: fakeYouTubeService,
            lyricsService: fakeLyricsService,
          ),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: PlaylistDetailScreen(playlist: playlist),
      ),
    );
  }

  group('PlaylistDetailScreen Widget Tests', () {
    testWidgets(
      'Scenario 2: Sync button is NOT shown in AppBar actions when youtubePlaylistUrl is null or empty',
      (tester) async {
        final manualPlaylist = Playlist(
          id: 'pl-manual',
          name: 'Manual Jam',
          youtubePlaylistUrl: null,
          songIds: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await fakePlaylistRepo.savePlaylist(manualPlaylist);

        await tester.pumpWidget(buildSubject(playlist: manualPlaylist));
        await tester.pumpAndSettle();

        expect(find.text('Manual Jam'), findsOneWidget);
        // Delete button is present
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
        // Sync button is NOT present
        expect(find.byIcon(Icons.sync), findsNothing);
      },
    );

    testWidgets(
      'Sync button is shown in AppBar actions next to delete button when youtubePlaylistUrl is present',
      (tester) async {
        final ytPlaylist = Playlist(
          id: 'pl-yt',
          name: 'YouTube Set',
          youtubePlaylistUrl: 'https://www.youtube.com/playlist?list=PL123',
          songIds: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await fakePlaylistRepo.savePlaylist(ytPlaylist);

        await tester.pumpWidget(buildSubject(playlist: ytPlaylist));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.sync), findsOneWidget);
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      },
    );

    testWidgets(
      'Scenario 1: Tapping sync updates playlist and displays "+1 añadida, -1 removida"',
      (tester) async {
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
        await fakeSongRepo.saveSong(songA);
        await fakeSongRepo.saveSong(songB);

        final playlist = Playlist(
          id: 'pl-1',
          name: 'Concert Set',
          youtubePlaylistUrl: 'https://www.youtube.com/playlist?list=PL1',
          songIds: ['song-A', 'song-B'],
          createdAt: now,
          updatedAt: now,
        );
        await fakePlaylistRepo.savePlaylist(playlist);

        // Remote contains [B, C]
        fakeYouTubeService.playlistToReturn = YouTubePlaylistMetadata(
          id: 'PL1',
          title: 'Remote Playlist',
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

        await tester.pumpWidget(buildSubject(
          playlist: playlist,
          locale: const Locale('es'),
        ));
        await tester.pumpAndSettle();

        // Verify initial playlist songs [A, B]
        expect(find.text('Song A'), findsOneWidget);
        expect(find.text('Song B'), findsOneWidget);
        expect(find.text('Song C'), findsNothing);

        // Tap sync button
        await tester.tap(find.byIcon(Icons.sync));
        await tester.pumpAndSettle();

        // Verify SnackBar feedback
        expect(find.text('+1 añadida, -1 removida'), findsOneWidget);

        // Verify updated playlist in UI
        expect(find.text('Song A'), findsNothing);
        expect(find.text('Song B'), findsOneWidget);
        expect(find.text('Song C'), findsOneWidget);

        final updatedPlaylist = await fakePlaylistRepo.getPlaylistById('pl-1');
        expect(updatedPlaylist!.songIds.contains('song-A'), isFalse);
        expect(updatedPlaylist.songIds.contains('song-B'), isTrue);
      },
    );

    testWidgets(
      'Scenario 3: Error during sync shows error snackbar and keeps playlist intact',
      (tester) async {
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
        await fakeSongRepo.saveSong(songA);

        final playlist = Playlist(
          id: 'pl-error',
          name: 'Private Playlist',
          youtubePlaylistUrl: 'https://www.youtube.com/playlist?list=PL_PRIVATE',
          songIds: ['song-A'],
          createdAt: now,
          updatedAt: now,
        );
        await fakePlaylistRepo.savePlaylist(playlist);

        fakeYouTubeService.shouldThrow = true;

        await tester.pumpWidget(buildSubject(
          playlist: playlist,
          locale: const Locale('es'),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Song A'), findsOneWidget);

        // Tap sync button
        await tester.tap(find.byIcon(Icons.sync));
        await tester.pumpAndSettle();

        // Error SnackBar is shown
        expect(
          find.text('No se pudo sincronizar la lista. Verifica el enlace y tu conexión.'),
          findsOneWidget,
        );

        // Playlist in repository remains intact
        final intact = await fakePlaylistRepo.getPlaylistById('pl-error');
        expect(intact!.songIds, ['song-A']);
        expect(find.text('Song A'), findsOneWidget);
      },
    );
  });
}

