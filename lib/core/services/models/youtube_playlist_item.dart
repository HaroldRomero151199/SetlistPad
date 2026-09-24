class YouTubePlaylistItem {
  final String videoId;
  final String title;
  final String artist;
  final String rawTitle;
  final String? thumbnailUrl;
  final String url;

  YouTubePlaylistItem({
    required this.videoId,
    required this.title,
    required this.artist,
    required this.rawTitle,
    this.thumbnailUrl,
    required this.url,
  });
}
