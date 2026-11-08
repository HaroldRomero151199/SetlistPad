import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setlist_pad/features/songs/songs.dart';
import '../../../../fakes/fake_lyrics_export_service.dart';
import '../../../../fakes/fake_translation_service.dart';

void main() {
  group('BilingualLyricsNotifier Tests', () {
    late Song song;
    late FakeTranslationService fakeTranslationService;
    late FakeLyricsExportService fakeExportService;

    setUp(() {
      song = Song(
        id: 'song-1',
        title: 'Title',
        artist: 'Artist',
        lyrics: 'Original Line',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
      fakeTranslationService = FakeTranslationService();
      fakeExportService = FakeLyricsExportService();
    });

    test('initial state has default values', () {
      final notifier = BilingualLyricsNotifier();
      final state = notifier.build();

      expect(state.isBilingualMode, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.lines, isEmpty);
      expect(state.targetLanguage, 'es');
    });

    test('toggleBilingualMode triggers translation on first activation',
        () async {
      final container = ProviderContainer(
        overrides: [
          bilingualLyricsNotifierProvider.overrideWith(
            () => BilingualLyricsNotifier(
              translationService: fakeTranslationService,
              exportService: fakeExportService,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier =
          container.read(bilingualLyricsNotifierProvider.notifier);

      expect(
        container.read(bilingualLyricsNotifierProvider).isBilingualMode,
        isFalse,
      );

      await notifier.toggleBilingualMode(song);

      final state = container.read(bilingualLyricsNotifierProvider);
      expect(state.isBilingualMode, isTrue);
      expect(state.lines.length, 1);
      expect(state.lines.first.translation, contains('es'));
      expect(fakeTranslationService.callCount, 1);
    });

    test('setTargetLanguage updates language and re-translates when active',
        () async {
      final container = ProviderContainer(
        overrides: [
          bilingualLyricsNotifierProvider.overrideWith(
            () => BilingualLyricsNotifier(
              translationService: fakeTranslationService,
              exportService: fakeExportService,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier =
          container.read(bilingualLyricsNotifierProvider.notifier);
      await notifier.toggleBilingualMode(song);

      expect(fakeTranslationService.callCount, 1);

      await notifier.setTargetLanguage(song, 'fr');

      final state = container.read(bilingualLyricsNotifierProvider);
      expect(state.targetLanguage, 'fr');
      expect(fakeTranslationService.callCount, 2);
      expect(fakeTranslationService.lastLanguage, 'fr');
    });

    test('exportToTextFile populates exportedFilePath in state', () async {
      final container = ProviderContainer(
        overrides: [
          bilingualLyricsNotifierProvider.overrideWith(
            () => BilingualLyricsNotifier(
              translationService: fakeTranslationService,
              exportService: fakeExportService,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier =
          container.read(bilingualLyricsNotifierProvider.notifier);
      await notifier.toggleBilingualMode(song);

      final file = await notifier.exportToTextFile(song);

      expect(file, isNotNull);
      final state = container.read(bilingualLyricsNotifierProvider);
      expect(state.exportedFilePath, file!.path);
    });

    test(
        'toggling bilingual mode on a different song isolates state and sets new songId',
        () async {
      final container = ProviderContainer(
        overrides: [
          bilingualLyricsNotifierProvider.overrideWith(
            () => BilingualLyricsNotifier(
              translationService: fakeTranslationService,
              exportService: fakeExportService,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier =
          container.read(bilingualLyricsNotifierProvider.notifier);
      await notifier.toggleBilingualMode(song);
      expect(container.read(bilingualLyricsNotifierProvider).songId, 'song-1');

      final song2 = Song(
        id: 'song-2',
        title: 'Song 2',
        artist: 'Artist 2',
        lyrics: 'Lyrics 2',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      await notifier.toggleBilingualMode(song2);
      final state2 = container.read(bilingualLyricsNotifierProvider);
      expect(state2.songId, 'song-2');
      expect(state2.isBilingualMode, isTrue);
    });
  });
}
