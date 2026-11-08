import 'dart:io';
import 'package:setlist_pad/core/services/services.dart';
import 'package:setlist_pad/features/songs/songs.dart';

/// Test double for LyricsExportService
class FakeLyricsExportService extends LyricsExportService {
  @override
  Future<File> exportBilingualLyrics({
    required String title,
    required String artist,
    required List<BilingualLine> lines,
    required String targetLanguage,
    Directory? destinationDirectory,
  }) async {
    return File('test_export.txt');
  }
}

