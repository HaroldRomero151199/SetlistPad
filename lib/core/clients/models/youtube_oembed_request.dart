/// Request parameters for fetching oEmbed data from YouTube
class YouTubeOembedRequest {
  final String url;
  final String format;

  const YouTubeOembedRequest({
    required this.url,
    this.format = 'json',
  });

  Map<String, String> toQueryParameters() {
    return {
      'url': url,
      'format': format,
    };
  }
}
