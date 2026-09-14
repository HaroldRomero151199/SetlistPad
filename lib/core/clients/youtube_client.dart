import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'models/youtube_models.dart';

/// HTTP client responsible for making direct requests to YouTube APIs (e.g. oEmbed).
class YouTubeClient {
  final http.Client _client;

  YouTubeClient({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches oEmbed metadata for a YouTube video using [YouTubeOembedRequest].
  /// Returns a strongly-typed [YouTubeOembedResponse].
  /// Throws [Exception] if the request fails or response status is not 200.
  Future<YouTubeOembedResponse> fetchOEmbedData(YouTubeOembedRequest request) async {
    final oembedUri = Uri.parse(ApiConfig.youtubeOembedBaseUrl).replace(
      queryParameters: request.toQueryParameters(),
    );

    final response = await _client.get(oembedUri);
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch YouTube oEmbed data: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return YouTubeOembedResponse.fromJson(data);
  }
}
