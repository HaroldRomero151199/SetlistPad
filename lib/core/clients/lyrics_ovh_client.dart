import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'models/lyrics_ovh_response.dart';

/// HTTP client for fetching lyrics from the open Lyrics.ovh API.
class LyricsOvhClient {
  final http.Client _client;

  LyricsOvhClient({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches lyrics by artist and title from Lyrics.ovh.
  /// Returns lyrics string if successful, or null on 404 or network failure.
  Future<String?> fetchLyrics({
    required String artist,
    required String title,
  }) async {
    final cleanArtist = Uri.encodeComponent(artist.trim());
    final cleanTitle = Uri.encodeComponent(title.trim());

    if (cleanArtist.isEmpty || cleanTitle.isEmpty) return null;

    final url = Uri.parse('${ApiConfig.lyricsOvhBaseUrl}/$cleanArtist/$cleanTitle');

    try {
      final response = await _client.get(
        url,
        headers: {'User-Agent': ApiConfig.appUserAgent},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final ovhResponse = LyricsOvhResponse.fromJson(data);
        if (ovhResponse.lyrics.trim().isNotEmpty) {
          return ovhResponse.lyrics.trim();
        }
      }
    } catch (_) {
      // Return null on network or decoding failure to allow fallback
    }

    return null;
  }
}
