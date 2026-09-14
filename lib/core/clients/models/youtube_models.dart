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

/// Strongly-typed response model for YouTube oEmbed API
class YouTubeOembedResponse {
  final String title;
  final String authorName;
  final String? authorUrl;
  final String? providerName;
  final String? providerUrl;
  final String? thumbnailUrl;
  final int? thumbnailWidth;
  final int? thumbnailHeight;
  final String? html;

  const YouTubeOembedResponse({
    required this.title,
    required this.authorName,
    this.authorUrl,
    this.providerName,
    this.providerUrl,
    this.thumbnailUrl,
    this.thumbnailWidth,
    this.thumbnailHeight,
    this.html,
  });

  factory YouTubeOembedResponse.fromJson(Map<String, dynamic> json) {
    return YouTubeOembedResponse(
      title: json['title'] as String? ?? 'Unknown Title',
      authorName: json['author_name'] as String? ?? 'Unknown Artist',
      authorUrl: json['author_url'] as String?,
      providerName: json['provider_name'] as String?,
      providerUrl: json['provider_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      thumbnailWidth: json['thumbnail_width'] as int?,
      thumbnailHeight: json['thumbnail_height'] as int?,
      html: json['html'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'title': title,
      'author_name': authorName,
    };
    if (authorUrl != null) data['author_url'] = authorUrl;
    if (providerName != null) data['provider_name'] = providerName;
    if (providerUrl != null) data['provider_url'] = providerUrl;
    if (thumbnailUrl != null) data['thumbnail_url'] = thumbnailUrl;
    if (thumbnailWidth != null) data['thumbnail_width'] = thumbnailWidth;
    if (thumbnailHeight != null) data['thumbnail_height'] = thumbnailHeight;
    if (html != null) data['html'] = html;
    return data;
  }
}
