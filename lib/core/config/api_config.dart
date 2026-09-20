/// Configuration and endpoint constants for external API clients
abstract final class ApiConfig {
  // LRCLIB API Configuration
  static const String lrclibBaseUrl = 'https://lrclib.net/api';
  static const String lrclibGetPath = '/get';
  static const String lrclibSearchPath = '/search';
  static const String appUserAgent =
      'SetlistPad/1.0 (https://github.com/HaroldRomero151199/SetlistPad)';

  // YouTube API Configuration
  static const String youtubeOembedBaseUrl = 'https://www.youtube.com/oembed';
  static const String youtubeWatchBaseUrl = 'https://www.youtube.com/watch';
  static const String youtubePlaylistBaseUrl = 'https://www.youtube.com/playlist';
  static const String youtubeFeedsVideosUrl =
      'https://www.youtube.com/feeds/videos.xml';
}
