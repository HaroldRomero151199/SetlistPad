/// Strongly-typed track item from a YouTube playlist
class YouTubePlaylistTrackItem {
  final String videoId;
  final String title;
  final String author;
  final String? thumbnailUrl;
  final String videoUrl;

  const YouTubePlaylistTrackItem({
    required this.videoId,
    required this.title,
    required this.author,
    this.thumbnailUrl,
    required this.videoUrl,
  });

  factory YouTubePlaylistTrackItem.fromJson(Map<String, dynamic> json) {
    return YouTubePlaylistTrackItem(
      videoId: json['videoId'] as String? ?? '',
      title: json['title'] as String? ?? 'Unknown Title',
      author: json['author'] as String? ?? 'Unknown Artist',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      videoUrl: json['videoUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'title': title,
      'author': author,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
    };
  }
}
