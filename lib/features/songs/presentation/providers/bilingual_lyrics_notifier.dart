import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/services/services.dart';
import '../../domain/models/song_model.dart';
import '../utils/bilingual_lyrics_parser.dart';
import 'bilingual_lyrics_state.dart';

/// Manages state for interlinear bilingual translation, language changes, and text export
class BilingualLyricsNotifier extends Notifier<BilingualLyricsState> {
  final TranslationService? _translationService;
  final LyricsExportService? _exportService;
  final BilingualLyricsParser? _parser;
  int _currentRequestId = 0;

  BilingualLyricsNotifier({
    TranslationService? translationService,
    LyricsExportService? exportService,
    BilingualLyricsParser? parser,
  })  : _translationService = translationService,
        _exportService = exportService,
        _parser = parser;

  TranslationService get translationService =>
      _translationService ?? ref.read(translationServiceProvider);

  LyricsExportService get exportService =>
      _exportService ?? ref.read(lyricsExportServiceProvider);

  BilingualLyricsParser get parser =>
      _parser ?? ref.read(bilingualLyricsParserProvider);

  @override
  BilingualLyricsState build() {
    return const BilingualLyricsState();
  }

  /// Resets bilingual state back to initial default
  void reset() {
    _currentRequestId++;
    state = const BilingualLyricsState();
  }

  /// Toggles bilingual interlinear view for a specific song
  Future<void> toggleBilingualMode(Song song) async {
    final isSameSong = state.songId == song.id;
    final newMode = isSameSong ? !state.isBilingualMode : true;

    // Keep current lines if already present, or immediately populate original lines so lyrics never vanish
    final initialLines = (isSameSong && state.lines.isNotEmpty)
        ? state.lines
        : parser.parse(originalLyrics: song.lyrics);

    state = state.copyWith(
      songId: song.id,
      isBilingualMode: newMode,
      lines: initialLines,
      clearErrorMessage: true,
    );

    if (newMode && song.lyrics.trim().isNotEmpty) {
      await translate(song);
    }
  }

  /// Changes the target translation language and re-translates if active
  Future<void> setTargetLanguage(Song song, String newLanguage) async {
    if (state.targetLanguage == newLanguage && state.songId == song.id) return;

    state = state.copyWith(
      songId: song.id,
      targetLanguage: newLanguage,
      clearErrorMessage: true,
    );

    if (state.isBilingualMode && song.lyrics.trim().isNotEmpty) {
      await translate(song);
    }
  }

  /// Translates lyrics to the current target language with caching and error resilience
  Future<void> translate(Song song, {bool forceRefresh = false}) async {
    if (song.lyrics.trim().isEmpty) {
      state = state.copyWith(songId: song.id, lines: const []);
      return;
    }

    final requestId = ++_currentRequestId;
    final targetLang = state.targetLanguage;
    final currentSongId = song.id;

    // Preserve existing lines or original lines so lyrics remain readable during translation
    final baseLines = (state.songId == song.id && state.lines.isNotEmpty)
        ? state.lines
        : parser.parse(originalLyrics: song.lyrics);

    state = state.copyWith(
      songId: song.id,
      lines: baseLines,
      isLoading: true,
      clearErrorMessage: true,
    );

    try {
      if (forceRefresh) {
        await translationService.clearCache(
          songId: song.id,
          lyrics: song.lyrics,
          targetLanguage: targetLang,
        );
      }

      final bilingualLines = await translationService.translateLyrics(
        lyrics: song.lyrics,
        targetLanguage: targetLang,
        songId: song.id,
      );

      // Discard response if superseded by a newer request or if song changed
      if (requestId != _currentRequestId ||
          state.songId != currentSongId ||
          state.targetLanguage != targetLang) {
        return;
      }

      state = state.copyWith(
        songId: song.id,
        lines: bilingualLines,
        isLoading: false,
      );
    } catch (e) {
      if (requestId != _currentRequestId ||
          state.songId != currentSongId ||
          state.targetLanguage != targetLang) {
        return;
      }

      // Graceful fallback to original lines without crash
      final fallbackLines = parser.parse(originalLyrics: song.lyrics);
      state = state.copyWith(
        songId: song.id,
        lines: fallbackLines,
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Exports the alternating bilingual lyrics into a local .txt file
  Future<File?> exportToTextFile(
    Song song, {
    Directory? destinationDirectory,
  }) async {
    if (state.lines.isEmpty) return null;

    state = state.copyWith(isExporting: true, clearErrorMessage: true);

    try {
      final file = await exportService.exportBilingualLyrics(
        title: song.title,
        artist: song.artist,
        lines: state.lines,
        targetLanguage: state.targetLanguage,
        destinationDirectory: destinationDirectory,
      );

      state = state.copyWith(
        isExporting: false,
        exportedFilePath: file.path,
      );
      return file;
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }
}

final bilingualLyricsNotifierProvider =
    NotifierProvider<BilingualLyricsNotifier, BilingualLyricsState>(
  BilingualLyricsNotifier.new,
);
