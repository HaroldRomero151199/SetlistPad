import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setlist_pad/core/providers/providers.dart';
import 'package:setlist_pad/core/services/services.dart';
import 'package:setlist_pad/features/playlists/playlists.dart';
import 'package:setlist_pad/features/songs/songs.dart';
import 'package:setlist_pad/l10n/app_localizations.dart';
import '../../../fakes/fake_playlist_repository.dart';
import '../../../fakes/fake_song_repository.dart';

void main() {
  late FakeSongRepository fakeSongRepo;
  late FakePlaylistRepository fakePlaylistRepo;

  setUp(() {
    fakeSongRepo = FakeSongRepository();
    fakePlaylistRepo = FakePlaylistRepository();
  });

  Widget buildSubject({Locale locale = const Locale('es')}) {
    final youtubeService = YouTubeService();
    final lyricsService = LyricsService();
    return ProviderScope(
      overrides: [
        songRepositoryProvider.overrideWithValue(fakeSongRepo),
        playlistRepositoryProvider.overrideWithValue(fakePlaylistRepo),
        youtubeServiceProvider.overrideWithValue(youtubeService),
        lyricsServiceProvider.overrideWithValue(lyricsService),
        songsNotifierProvider.overrideWith(
          () => SongsNotifier(
            repository: fakeSongRepo,
            playlistRepository: fakePlaylistRepo,
            youtubeService: youtubeService,
            lyricsService: lyricsService,
          ),
        ),
        playlistsNotifierProvider.overrideWith(
          () => PlaylistsNotifier(
            repository: fakePlaylistRepo,
            songRepository: fakeSongRepo,
            youtubeService: youtubeService,
            lyricsService: lyricsService,
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
        home: const SongsScreen(),
      ),
    );
  }

  group('SongsScreen Delete Confirmation Tests', () {
    testWidgets(
      'deleting a song opens confirmation dialog and keeps song on Cancel',
      (tester) async {
        final now = DateTime.now();
        await fakeSongRepo.saveSong(
          Song(
            id: 'song-1',
            title: 'Yesterday',
            artist: 'The Beatles',
            lyrics: 'All my troubles...',
            createdAt: now,
            updatedAt: now,
          ),
        );

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.text('Yesterday'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Eliminar canción'), findsOneWidget);
        expect(
          find.text(
            '¿Estás seguro de que deseas eliminar "Yesterday" de tu biblioteca? También se quitará de todas las listas de reproducción.',
          ),
          findsOneWidget,
        );

        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text('Yesterday'), findsOneWidget);
        expect(await fakeSongRepo.getSongById('song-1'), isNotNull);
      },
    );

    testWidgets(
      'confirming song deletion removes song from library and playlists and shows SnackBar',
      (tester) async {
        final now = DateTime.now();
        await fakeSongRepo.saveSong(
          Song(
            id: 'song-2',
            title: 'Yesterday',
            artist: 'The Beatles',
            lyrics: 'All my troubles...',
            createdAt: now,
            updatedAt: now,
          ),
        );
        await fakePlaylistRepo.savePlaylist(
          Playlist(
            id: 'pl-1',
            name: 'Classics',
            songIds: const ['song-2'],
            createdAt: now,
            updatedAt: now,
          ),
        );

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text('Yesterday'), findsNothing);
        expect(
          find.text('Se eliminó "Yesterday" de la biblioteca'),
          findsOneWidget,
        );
        expect(await fakeSongRepo.getSongById('song-2'), isNull);
        final pl = await fakePlaylistRepo.getPlaylistById('pl-1');
        expect(pl?.songIds, isEmpty);
      },
    );
  });
}
