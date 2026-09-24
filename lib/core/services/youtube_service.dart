import '../clients/clients.dart';
import 'models/youtube_metadata.dart';
import 'models/youtube_playlist_item.dart';
import 'models/youtube_playlist_metadata.dart';
import 'utils/track_title_sanitizer.dart';

class YouTubeService {
  final YouTubeClient client;
  final TrackTitleSanitizer sanitizer;

  YouTubeService({
    YouTubeClient? client,
    TrackTitleSanitizer? sanitizer,
  })  : client = client ?? YouTubeClient(),
        sanitizer = sanitizer ?? const TrackTitleSanitizer();

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

  /// Checks whether a URL is a YouTube playlist URL
  bool isPlaylistUrl(String url) {
    final trimmed = url.trim();
    if (!trimmed.contains('youtube.com') && !trimmed.contains('youtu.be')) {
      return false;
    }
    if (trimmed.contains('/playlist')) {
      return true;
    }
    final playlistId = extractPlaylistId(trimmed);
    final videoId = extractVideoId(trimmed);
    return playlistId != null && videoId == null;
  }

  /// Fetches metadata and parsed tracks for a YouTube playlist
  Future<YouTubePlaylistMetadata> fetchPlaylistMetadata(
    String playlistUrl,
  ) async {
    final playlistId = extractPlaylistId(playlistUrl);
    if (playlistId == null || playlistId.isEmpty) {
      throw const FormatException('Invalid YouTube playlist URL format');
    }

    final response = await client.fetchPlaylistData(
      YouTubePlaylistRequest(playlistId: playlistId),
    );

    final items = response.tracks.map((track) {
      final parsed = parseTitleAndArtist(track.title, track.author);
      return YouTubePlaylistItem(
        videoId: track.videoId,
        title: parsed['title']!,
        artist: parsed['artist']!,
        rawTitle: track.title,
        thumbnailUrl: track.thumbnailUrl,
        url: track.videoUrl,
      );
    }).toList();

    return YouTubePlaylistMetadata(
      id: playlistId,
      title: response.title,
      author: response.author,
      items: items,
    );
  }

  /// Fetches metadata for a single YouTube video using open oEmbed endpoint
  Future<YouTubeMetadata> fetchVideoMetadata(String youtubeUrl) async {
    final videoId = extractVideoId(youtubeUrl);
    if (videoId == null) {
      throw const FormatException('Invalid YouTube URL format');
    }

    final canonicalUrl = '\${ApiConfig.youtubeWatchBaseUrl}?v=\$videoId';
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

  /// Parses raw video title and channel/author into clean artist and title using [TrackTitleSanitizer]
  Map<String, String> parseTitleAndArtist(String rawTitle, String fallbackAuthor) {
    return sanitizer.parse(rawTitle, fallbackAuthor);
  }
}
