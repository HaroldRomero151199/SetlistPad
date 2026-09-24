import 'youtube_playlist_track_item.dart';

/// Strongly-typed response model for a YouTube playlist
class YouTubePlaylistResponse {
  final String playlistId;
  final String title;
  final String? author;
  final List<YouTubePlaylistTrackItem> tracks;

  const YouTubePlaylistResponse({
    required this.playlistId,
    required this.title,
    this.author,
    required this.tracks,
  });

  factory YouTubePlaylistResponse.fromJson(Map<String, dynamic> json) {
    final tracksList = (json['tracks'] as List<dynamic>?)
            ?.map((e) =>
                YouTubePlaylistTrackItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return YouTubePlaylistResponse(
      playlistId: json['playlistId'] as String? ?? '',
      title: json['title'] as String? ?? 'YouTube Playlist',
      author: json['author'] as String?,
      tracks: tracksList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playlistId': playlistId,
      'title': title,
      if (author != null) 'author': author,
      'tracks': tracks.map((t) => t.toJson()).toList(),
    };
  }
}
