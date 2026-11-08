import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../features/songs/domain/models/bilingual_line.dart';
import '../../features/songs/presentation/utils/bilingual_lyrics_parser.dart';

/// Storage service responsible for formatting and exporting bilingual lyrics to local .txt files
class LyricsExportService {
  final BilingualLyricsParser _parser;
  final Future<Directory> Function()? _directoryProvider;

  LyricsExportService({
    BilingualLyricsParser? parser,
    Future<Directory> Function()? directoryProvider,
  })  : _parser = parser ?? const BilingualLyricsParser(),
        _directoryProvider = directoryProvider;

  /// Sanitizes string to be safe for filenames across operating systems
  String sanitizeFileName(String input) {
    final sanitized = input
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return sanitized.isEmpty ? 'lyrics' : sanitized;
  }

  /// Exports bilingual lines to a .txt file and returns the generated [File]
  Future<File> exportBilingualLyrics({
    required String title,
    required String artist,
    required List<BilingualLine> lines,
    required String targetLanguage,
    Directory? destinationDirectory,
  }) async {
    final directory = destinationDirectory ??
        (_directoryProvider != null
            ? await _directoryProvider()
            : await getApplicationDocumentsDirectory());

    final cleanTitle = sanitizeFileName(title);
    final cleanArtist = sanitizeFileName(artist);
    final cleanLang = sanitizeFileName(targetLanguage).toLowerCase();
    final fileName = '${cleanArtist}_${cleanTitle}_bilingual_$cleanLang.txt';
    final filePath = '${directory.path}/$fileName';

    final content = _parser.formatAlternatingText(
      lines: lines,
      title: title,
      artist: artist,
      targetLanguage: targetLanguage,
    );

    final file = File(filePath);
    await file.writeAsString(content, flush: true);
    return file;
  }
}

