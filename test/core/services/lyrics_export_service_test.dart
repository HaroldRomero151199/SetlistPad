import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:setlist_pad/core/services/services.dart';
import 'package:setlist_pad/features/songs/songs.dart';

void main() {
  group('LyricsExportService Tests', () {
    late Directory tempDir;
    late LyricsExportService exportService;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('export_test_');
      exportService = LyricsExportService(
        directoryProvider: () async => tempDir,
      );
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('sanitizeFileName removes illegal filesystem characters', () {
      expect(
        exportService.sanitizeFileName('AC/DC: "Back in Black" ?*<>|'),
        'AC_DC_Back_in_Black',
      );
      expect(exportService.sanitizeFileName('   '), 'lyrics');
    });

    test('exportBilingualLyrics creates and writes .txt file correctly',
        () async {
      const lines = [
        BilingualLine(
          lineNumber: 1,
          original: 'Hello my friend',
          translation: 'Hola mi amigo',
        ),
        BilingualLine(
          lineNumber: 2,
          original: '',
          translation: '',
        ),
        BilingualLine(
          lineNumber: 3,
          original: 'Goodbye now',
          translation: 'Adiós ahora',
        ),
      ];

      final file = await exportService.exportBilingualLyrics(
        title: 'My Song',
        artist: 'The Band',
        lines: lines,
        targetLanguage: 'es',
        destinationDirectory: tempDir,
      );

      expect(file.existsSync(), isTrue);
      expect(file.path.endsWith('.txt'), isTrue);

      final content = await file.readAsString();
      expect(content, contains('My Song - The Band'));
      expect(content, contains('Translation (ES)'));
      expect(content, contains('Hello my friend\nHola mi amigo'));
      expect(content, contains('Goodbye now\nAdiós ahora'));
    });
  });
}

