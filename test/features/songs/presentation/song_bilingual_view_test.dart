import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setlist_pad/core/providers/providers.dart';
import 'package:setlist_pad/features/songs/songs.dart';
import 'package:setlist_pad/l10n/app_localizations.dart';
import '../../../fakes/fake_lyrics_export_service.dart';
import '../../../fakes/fake_song_repository.dart';
import '../../../fakes/fake_translation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SongBilingualLyricsView & Widgets Tests', () {
    testWidgets('SongBilingualLyricsView renders original and translated lines',
        (tester) async {
      const lines = [
        BilingualLine(
          lineNumber: 1,
          original: 'Original Line 1',
          translation: 'Línea Traducida 1',
        ),
        BilingualLine(
          lineNumber: 2,
          original: '',
          translation: '',
        ),
        BilingualLine(
          lineNumber: 3,
          original: 'Original Line 2',
          translation: 'Línea Traducida 2',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SongBilingualLyricsView(
              lines: lines,
              fontSize: 16.0,
            ),
          ),
        ),
      );

      expect(find.text('Original Line 1'), findsOneWidget);
      expect(find.text('Línea Traducida 1'), findsOneWidget);
      expect(find.text('Original Line 2'), findsOneWidget);
      expect(find.text('Línea Traducida 2'), findsOneWidget);
    });

    testWidgets(
        'SongBilingualLyricsView displays loading indicator while keeping original lyrics visible',
        (tester) async {
      const lines = [
        BilingualLine(
          lineNumber: 1,
          original: 'Keep me visible while translating',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SongBilingualLyricsView(
              lines: lines,
              fontSize: 16.0,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Keep me visible while translating'), findsOneWidget);
    });

    testWidgets('SongBilingualLyricsView displays error message and retry',
        (tester) async {
      var retryCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SongBilingualLyricsView(
              lines: const [],
              fontSize: 16.0,
              errorMessage: 'Failed network connection',
              onRetry: () => retryCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Failed network connection'), findsOneWidget);
      await tester.tap(find.text('Reintentar'));
      expect(retryCalled, isTrue);
    });

    testWidgets(
        'SongDetailScreen enters bilingual mode and displays language selector and export button',
        (tester) async {
      final repo = FakeSongRepository();
      final song = Song(
        id: 'song-test-1',
        title: 'Bilingual Song',
        artist: 'Singer',
        lyrics: 'Hello World',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
      repo.saveSong(song);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            songRepositoryProvider.overrideWithValue(repo),
            songsNotifierProvider.overrideWith(
              () => SongsNotifier(repository: repo),
            ),
            translationServiceProvider.overrideWithValue(
              FakeTranslationService(),
            ),
            lyricsExportServiceProvider.overrideWithValue(
              FakeLyricsExportService(),
            ),
            bilingualLyricsNotifierProvider.overrideWith(
              () => BilingualLyricsNotifier(
                translationService: FakeTranslationService(),
                exportService: FakeLyricsExportService(),
              ),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('es'), Locale('en')],
            locale: const Locale('es'),
            home: SongDetailScreen(song: song),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find bilingual toggle icon in AppBar
      final bilingualToggle = find.byTooltip('Letras Bilingües');
      expect(bilingualToggle, findsOneWidget);

      // Tap bilingual toggle
      await tester.tap(bilingualToggle);
      await tester.pumpAndSettle();

      // Should now show language selector and translated lines
      expect(find.byType(BilingualLanguageSelector), findsOneWidget);
      expect(find.text('Hola Mundo (es)'), findsOneWidget);

      // Should show export button in AppBar
      final exportButton = find.byTooltip('Exportar (.txt)');
      expect(exportButton, findsOneWidget);

      // Tap export button
      await tester.tap(exportButton);
      await tester.pumpAndSettle();

      // Verify success snackbar
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets(
        'Opening a different song does NOT show bilingual mode even if another song was translated',
        (tester) async {
      final repo = FakeSongRepository();
      final song1 = Song(
        id: 'song-1',
        title: 'Song One',
        artist: 'Singer 1',
        lyrics: 'Line from song one',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
      final song2 = Song(
        id: 'song-2',
        title: 'Song Two',
        artist: 'Singer 2',
        lyrics: 'Line from song two',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
      repo.saveSong(song1);
      repo.saveSong(song2);

      final fakeTranslation = FakeTranslationService();
      final fakeExport = FakeLyricsExportService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            songRepositoryProvider.overrideWithValue(repo),
            songsNotifierProvider.overrideWith(
              () => SongsNotifier(repository: repo),
            ),
            translationServiceProvider.overrideWithValue(fakeTranslation),
            lyricsExportServiceProvider.overrideWithValue(fakeExport),
            bilingualLyricsNotifierProvider.overrideWith(
              () => BilingualLyricsNotifier(
                translationService: fakeTranslation,
                exportService: fakeExport,
              ),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('es'),
            home: SongDetailScreen(song: song2),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Song 2 must NOT show bilingual view or language selector
      expect(find.byType(BilingualLanguageSelector), findsNothing);
      expect(find.text('Line from song two'), findsOneWidget);
    });
  });
}

