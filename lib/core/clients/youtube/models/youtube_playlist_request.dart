class YouTubePlaylistRequest {
  final String playlistId;

  const YouTubePlaylistRequest({
    required this.playlistId,
  });

  Map<String, String> toQueryParameters() {
    return {
      'list': playlistId,
    };
  }
}
