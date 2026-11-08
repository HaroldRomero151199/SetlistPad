import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import 'models/translation_request.dart';
import 'models/translation_response.dart';

/// HTTP client for querying translation endpoints with graceful fallback
class TranslationClient {
  final http.Client _client;
  final String _baseUrl;

  TranslationClient({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.translationBaseUrl;

  /// Translates text according to [request]. Returns [TranslationResponse] or null on failure.
  Future<TranslationResponse?> translate(TranslationRequest request) async {
    if (request.text.trim().isEmpty) {
      return const TranslationResponse(
        translatedText: '',
        statusCode: 200,
      );
    }

    try {
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: request.toQueryParams(),
      );

      final response = await _client.get(
        uri,
        headers: {
          'User-Agent': ApiConfig.appUserAgent,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return TranslationResponse.fromJson(data);
      }
    } catch (_) {
      // Graceful fallback on network or parsing failure
    }

    return null;
  }

  /// Convenience method returning translated string directly, or null on error
  Future<String?> translateText({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    final cleanTarget = targetLanguage.toLowerCase().trim();
    final resolvedSource = (sourceLanguage != null && sourceLanguage.trim().isNotEmpty)
        ? sourceLanguage.toLowerCase().trim()
        : (cleanTarget == 'en' ? 'es' : 'en');

    final response = await translate(
      TranslationRequest(
        text: text,
        targetLanguage: cleanTarget,
        sourceLanguage: resolvedSource,
      ),
    );

    if (response != null && response.isSuccessful) {
      return response.translatedText;
    }
    return null;
  }
}

