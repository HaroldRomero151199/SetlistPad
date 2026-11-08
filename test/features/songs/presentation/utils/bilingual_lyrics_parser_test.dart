import 'package:flutter_test/flutter_test.dart';
import 'package:setlist_pad/features/songs/songs.dart';

void main() {
  group('BilingualLyricsParser Tests', () {
    const parser = BilingualLyricsParser();

    test('splitLines splits on newlines and preserves blank lines', () {
      const input = 'Line 1\r\n\r\nLine 2\nLine 3';
      final lines = parser.splitLines(input);

      expect(lines, ['Line 1', '', 'Line 2', 'Line 3']);
    });

    test('splitLines returns empty list for empty string', () {
      expect(parser.splitLines(''), isEmpty);
    });

    test('parse aligns original and translated lines without desynchronizing',
        () {
      const original = 'Hello world\n\nI love music\nGoodbye';
      const translated = 'Hola mundo\n\nMe encanta la música\nAdiós';

      final result = parser.parse(
        originalLyrics: original,
        translatedLyrics: translated,
      );

      expect(result.length, 4);

      expect(result[0].lineNumber, 1);
      expect(result[0].original, 'Hello world');
      expect(result[0].translation, 'Hola mundo');
      expect(result[0].isBlank, isFalse);
      expect(result[0].hasTranslation, isTrue);

      // Blank line preserved
      expect(result[1].lineNumber, 2);
      expect(result[1].original, '');
      expect(result[1].translation, '');
      expect(result[1].isBlank, isTrue);

      expect(result[2].lineNumber, 3);
      expect(result[2].original, 'I love music');
      expect(result[2].translation, 'Me encanta la música');

      expect(result[3].lineNumber, 4);
      expect(result[3].original, 'Goodbye');
      expect(result[3].translation, 'Adiós');
    });

    test('parse handles missing or shorter translated lines gracefully', () {
      const original = 'Line 1\nLine 2\nLine 3';
      const translated = 'Línea 1';

      final result = parser.parse(
        originalLyrics: original,
        translatedLyrics: translated,
      );

      expect(result.length, 3);
      expect(result[0].translation, 'Línea 1');
      expect(result[1].translation, isNull);
      expect(result[2].translation, isNull);
      expect(result[1].effectiveTranslation, 'Line 2');
    });

    test('formatAlternatingText produces correct alternating .txt format', () {
      const original = 'First verse\n\nSecond verse';
      const translated = 'Primer verso\n\nSegundo verso';

      final lines = parser.parse(
        originalLyrics: original,
        translatedLyrics: translated,
      );

      final formatted = parser.formatAlternatingText(
        lines: lines,
        title: 'Song Title',
        artist: 'The Artist',
        targetLanguage: 'ES',
      );

      expect(formatted, contains('Song Title - The Artist'));
      expect(formatted, contains('Translation (ES)'));
      expect(formatted, contains('First verse\nPrimer verso'));
      expect(formatted, contains('Second verse\nSegundo verso'));
    });
  });
}

