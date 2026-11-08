import '../../domain/models/bilingual_line.dart';

/// Pure utility for splitting, aligning, and formatting bilingual lyrics
class BilingualLyricsParser {
  const BilingualLyricsParser();

  /// Splits lyrics into lines while preserving empty lines and normalizing line endings
  List<String> splitLines(String text) {
    if (text.isEmpty) return const [];
    // Normalize \r\n to \n and split
    return text.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
  }

  /// Parses original lyrics and translated lyrics into synchronized [BilingualLine] entries
  List<BilingualLine> parse({
    required String originalLyrics,
    String? translatedLyrics,
  }) {
    final originalLines = splitLines(originalLyrics);
    if (originalLines.isEmpty) return const [];

    final translatedLines =
        translatedLyrics != null ? splitLines(translatedLyrics) : const <String>[];

    final result = <BilingualLine>[];
    var transIdx = 0;

    for (var i = 0; i < originalLines.length; i++) {
      final orig = originalLines[i];
      if (orig.trim().isEmpty) {
        // Stanza separator or empty line
        result.add(
          BilingualLine(
            lineNumber: i + 1,
            original: orig,
            translation: '',
          ),
        );
        // If translated lines also had an empty line at this position, advance it
        if (transIdx < translatedLines.length &&
            translatedLines[transIdx].trim().isEmpty) {
          transIdx++;
        }
      } else {
        String? trans;
        if (transIdx < translatedLines.length) {
          // If translation line is empty while original is not, check next non-empty or use it
          trans = translatedLines[transIdx];
          transIdx++;
        }
        result.add(
          BilingualLine(
            lineNumber: i + 1,
            original: orig,
            translation: trans,
          ),
        );
      }
    }

    return result;
  }

  /// Formats aligned bilingual lines into alternating plain-text format for .txt export
  String formatAlternatingText({
    required List<BilingualLine> lines,
    String? title,
    String? artist,
    String? targetLanguage,
  }) {
    final buffer = StringBuffer();

    if (title != null && title.isNotEmpty) {
      if (artist != null && artist.isNotEmpty) {
        buffer.writeln('$title - $artist');
      } else {
        buffer.writeln(title);
      }
      if (targetLanguage != null && targetLanguage.isNotEmpty) {
        buffer.writeln('Translation (${targetLanguage.toUpperCase()})');
      }
      buffer.writeln('=' * 40);
      buffer.writeln();
    }

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.isBlank) {
        buffer.writeln();
      } else {
        buffer.writeln(line.original);
        if (line.hasTranslation) {
          buffer.writeln(line.translation);
        }
        // Add a line break between pairs if the next line is also content
        if (i + 1 < lines.length && !lines[i + 1].isBlank) {
          buffer.writeln();
        }
      }
    }

    return buffer.toString().trimRight();
  }
}

