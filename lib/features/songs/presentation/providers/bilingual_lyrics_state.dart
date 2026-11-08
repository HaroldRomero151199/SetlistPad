import '../../domain/models/bilingual_line.dart';

/// State representation for interlinear bilingual lyrics mode, translation, and export
class BilingualLyricsState {
  final String? songId;
  final List<BilingualLine> lines;
  final bool isLoading;
  final bool isExporting;
  final String? errorMessage;
  final String targetLanguage;
  final bool isBilingualMode;
  final String? exportedFilePath;

  const BilingualLyricsState({
    this.songId,
    this.lines = const [],
    this.isLoading = false,
    this.isExporting = false,
    this.errorMessage,
    this.targetLanguage = 'es',
    this.isBilingualMode = false,
    this.exportedFilePath,
  });

  BilingualLyricsState copyWith({
    String? songId,
    bool clearSongId = false,
    List<BilingualLine>? lines,
    bool? isLoading,
    bool? isExporting,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? targetLanguage,
    bool? isBilingualMode,
    String? exportedFilePath,
    bool clearExportedFilePath = false,
  }) {
    return BilingualLyricsState(
      songId: clearSongId ? null : (songId ?? this.songId),
      lines: lines ?? this.lines,
      isLoading: isLoading ?? this.isLoading,
      isExporting: isExporting ?? this.isExporting,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      targetLanguage: targetLanguage ?? this.targetLanguage,
      isBilingualMode: isBilingualMode ?? this.isBilingualMode,
      exportedFilePath: clearExportedFilePath
          ? null
          : (exportedFilePath ?? this.exportedFilePath),
    );
  }
}
