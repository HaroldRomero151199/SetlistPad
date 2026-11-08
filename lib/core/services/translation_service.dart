import 'package:hive/hive.dart';
import '../clients/translation/translation_client.dart';
import '../../features/songs/domain/models/bilingual_line.dart';
import '../../features/songs/presentation/utils/bilingual_lyrics_parser.dart';

/// Domain service managing lyrics translation, interlinear alignment, and Hive caching
class TranslationService {
  final TranslationClient _client;
  final Box<String>? _cacheBox;
  final BilingualLyricsParser _parser;

  TranslationService({
    TranslationClient? client,
    Box<String>? cacheBox,
    BilingualLyricsParser? parser,
  })  : _client = client ?? TranslationClient(),
        _cacheBox = cacheBox,
        _parser = parser ?? const BilingualLyricsParser();

  /// Computes a unique cache key based on song ID (or lyrics hash) and target language
  String computeCacheKey({
    String? songId,
    required String lyrics,
    required String targetLanguage,
  }) {
    if (songId != null && songId.isNotEmpty) {
      return '${songId}_${targetLanguage.toLowerCase()}';
    }
    return '${lyrics.hashCode}_${targetLanguage.toLowerCase()}';
  }

  /// Translates full lyrics preserving structure, empty lines, and verse order.
  /// Checks Hive cache first to prevent redundant network requests.
  Future<List<BilingualLine>> translateLyrics({
    required String lyrics,
    required String targetLanguage,
    String? songId,
    String sourceLanguage = 'autodetect',
  }) async {
    if (lyrics.trim().isEmpty) return const [];

    final cacheKey = computeCacheKey(
      songId: songId,
      lyrics: lyrics,
      targetLanguage: targetLanguage,
    );

    // 1. Check local Hive cache
    if (_cacheBox != null && _cacheBox.isOpen) {
      final cached = _cacheBox.get(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        return _parser.parse(originalLyrics: lyrics, translatedLyrics: cached);
      }
    }

    final rawLines = _parser.splitLines(lyrics);
    final uniqueLines =
        rawLines.where((l) => l.trim().isNotEmpty).toSet().toList();

    // 2. Fetch translations for unique lines with graceful error fallback
    final translationMap = <String, String>{};
    for (final line in uniqueLines) {
      try {
        final translated = await _client.translateText(
          text: line.trim(),
          targetLanguage: targetLanguage,
          sourceLanguage: sourceLanguage,
        );
        if (translated != null && translated.isNotEmpty) {
          translationMap[line] = translated;
        }
      } catch (_) {
        // Keep translating remaining lines even if a single line fails
      }
    }

    // 3. Assemble full translated text matching original line positions
    final translatedLyrics = rawLines.map((line) {
      if (line.trim().isEmpty) return '';
      return translationMap[line] ?? '';
    }).join('\n');

    // 4. Cache translation in Hive if at least one translated line was resolved
    if (translationMap.isNotEmpty && _cacheBox != null && _cacheBox.isOpen) {
      await _cacheBox.put(cacheKey, translatedLyrics);
    }

    return _parser.parse(
      originalLyrics: lyrics,
      translatedLyrics: translatedLyrics,
    );
  }

  /// Evicts the cached translation for a given song and target language
  Future<void> clearCache({
    String? songId,
    required String lyrics,
    required String targetLanguage,
  }) async {
    if (_cacheBox != null && _cacheBox.isOpen) {
      final key = computeCacheKey(
        songId: songId,
        lyrics: lyrics,
        targetLanguage: targetLanguage,
      );
      await _cacheBox.delete(key);
    }
  }
}

