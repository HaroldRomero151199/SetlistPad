import 'youtube_playlist_item.dart';

class YouTubePlaylistMetadata {
  final String id;
  final String title;
  final String? author;
  final List<YouTubePlaylistItem> items;

  YouTubePlaylistMetadata({
    required this.id,
    required this.title,
    this.author,
    required this.items,
  });
}
