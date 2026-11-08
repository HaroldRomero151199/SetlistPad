import 'package:setlist_pad/core/services/services.dart';
import 'package:setlist_pad/features/songs/songs.dart';

/// Test double for TranslationService
class FakeTranslationService extends TranslationService {
  int callCount = 0;
  String? lastLanguage;

  @override
  Future<List<BilingualLine>> translateLyrics({
    required String lyrics,
    required String targetLanguage,
    String? songId,
    String? sourceLanguage,
  }) async {
    callCount++;
    lastLanguage = targetLanguage;
    final firstLine =
        lyrics.trim().isNotEmpty ? lyrics.split('\n').first : 'Hello World';
    return [
      BilingualLine(
        lineNumber: 1,
        original: firstLine,
        translation: 'Hola Mundo ($targetLanguage)',
      ),
    ];
  }
}

