import '../clients/models/youtube_models.dart';
import '../clients/youtube_client.dart';
import '../config/api_config.dart';

class YouTubeMetadata {
  final String title;
  final String artist;
  final String rawTitle;
  final String? thumbnailUrl;
  final String url;

  YouTubeMetadata({
    required this.title,
    required this.artist,
    required this.rawTitle,
    this.thumbnailUrl,
    required this.url,
  });
}

class YouTubeService {
  final YouTubeClient client;

  YouTubeService({YouTubeClient? client}) : client = client ?? YouTubeClient();

  /// Extracts YouTube Video ID from various URL formats, including Shorts and Live
  String? extractVideoId(String url) {
    final regExp = RegExp(
      r'^(?:https?:\/\/)?(?:www\.)?(?:m\.)?(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=|shorts\/|live\/))([\w-]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url.trim());
    return match?.group(1);
  }

  /// Extracts YouTube Playlist ID from URL
  String? extractPlaylistId(String url) {
    final regExp = RegExp(
      r'[?&]list=([^#&?]+)',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url.trim());
    return match?.group(1);
  }

  /// Fetches metadata for a single YouTube video using open oEmbed endpoint
  Future<YouTubeMetadata> fetchVideoMetadata(String youtubeUrl) async {
    final videoId = extractVideoId(youtubeUrl);
    if (videoId == null) {
      throw const FormatException('Invalid YouTube URL format');
    }

    final canonicalUrl = '${ApiConfig.youtubeWatchBaseUrl}?v=$videoId';
    final oembedResponse = await client.fetchOEmbedData(
      YouTubeOembedRequest(url: canonicalUrl),
    );

    final rawTitle = oembedResponse.title;
    final authorName = oembedResponse.authorName;
    final thumbnailUrl = oembedResponse.thumbnailUrl;

    final parsed = parseTitleAndArtist(rawTitle, authorName);

    return YouTubeMetadata(
      title: parsed['title']!,
      artist: parsed['artist']!,
      rawTitle: rawTitle,
      thumbnailUrl: thumbnailUrl,
      url: canonicalUrl,
    );
  }

  /// Helper to parse "Artist - Song Title (Official Video)" into artist and title
  Map<String, String> parseTitleAndArtist(String rawTitle, String fallbackAuthor) {
    // Clean common suffixes like (Official Video), [MV], (Lyric Video), etc.
    String cleanTitle = rawTitle
        .replaceAll(RegExp(r'\s*[\(\[](Official|Lyric|Music|Audio|HD|4K|\d{4}).*?[\)\]]', caseSensitive: false), '')
        .trim();

    // Look for a deliberate artist - title separator: whitespace around hyphen, en-dash, or em-dash
    final delimiterRegex = RegExp(r'\s+[-–—]\s+');
    final delimiterMatch = delimiterRegex.firstMatch(cleanTitle);

    if (delimiterMatch != null) {
      final artistPart = cleanTitle.substring(0, delimiterMatch.start).trim();
      final titlePart = cleanTitle.substring(delimiterMatch.end).trim();
      if (artistPart.isNotEmpty && titlePart.isNotEmpty) {
        return {'artist': artistPart, 'title': titlePart};
      }
    }

    // Fallback: author is channel name, cleanTitle is title
    String artist = fallbackAuthor.replaceAll(RegExp(r'VEVO$', caseSensitive: false), '').trim();
    if (artist.isEmpty) artist = 'Unknown Artist';

    return {'artist': artist, 'title': cleanTitle.isEmpty ? rawTitle : cleanTitle};
  }
}
