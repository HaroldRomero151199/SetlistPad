import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import 'models/get_lyrics_request.dart';
import 'models/lrclib_response.dart';
import 'models/search_lyrics_request.dart';

/// HTTP client responsible for making direct requests to the LRCLIB API.
class LrclibClient {
  final http.Client _client;
  static const Map<String, String> _defaultHeaders = {
    'User-Agent': ApiConfig.appUserAgent,
  };

  LrclibClient({http.Client? client}) : _client = client ?? http.Client();

  /// Gets lyrics by exact track title and artist match using [GetLyricsRequest].
  /// Returns [LrclibResponse], or null if not found or on network error.
  Future<LrclibResponse?> getLyrics(GetLyricsRequest request) async {
    final queryUri = Uri.parse('${ApiConfig.lrclibBaseUrl}${ApiConfig.lrclibGetPath}').replace(
      queryParameters: request.toQueryParameters(),
    );

    try {
      final response = await _client.get(queryUri, headers: _defaultHeaders);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return LrclibResponse.fromJson(data);
      }
    } catch (_) {
      // Ignore network errors to allow fallback in service layer
    }
    return null;
  }

  /// Searches lyrics with a query or field parameters using [SearchLyricsRequest].
  /// Returns a list of [LrclibResponse], or an empty list if none found.
  Future<List<LrclibResponse>> searchLyrics(SearchLyricsRequest request) async {
    final queryParams = request.toQueryParameters();
    if (queryParams.isEmpty) return [];

    final searchUri = Uri.parse('${ApiConfig.lrclibBaseUrl}${ApiConfig.lrclibSearchPath}').replace(
      queryParameters: queryParams,
    );

    try {
      final response = await _client.get(searchUri, headers: _defaultHeaders);
      if (response.statusCode == 200) {
        final results = jsonDecode(response.body) as List<dynamic>;
        return results
            .whereType<Map<String, dynamic>>()
            .map((item) => LrclibResponse.fromJson(item))
            .toList();
      }
    } catch (_) {}

    return [];
  }
}
