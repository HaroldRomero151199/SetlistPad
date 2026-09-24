class YouTubeOembedResponse {
  final String title;
  final String authorName;
  final String authorUrl;
  final String type;
  final int height;
  final int width;
  final String version;
  final String providerName;
  final String providerUrl;
  final String thumbnailUrl;
  final int thumbnailHeight;
  final int thumbnailWidth;
  final String html;

  const YouTubeOembedResponse({
    required this.title,
    required this.authorName,
    required this.authorUrl,
    required this.type,
    required this.height,
    required this.width,
    required this.version,
    required this.providerName,
    required this.providerUrl,
    required this.thumbnailUrl,
    required this.thumbnailHeight,
    required this.thumbnailWidth,
    required this.html,
  });

  factory YouTubeOembedResponse.fromJson(Map<String, dynamic> json) {
    return YouTubeOembedResponse(
      title: json['title'] as String? ?? '',
      authorName: json['author_name'] as String? ?? '',
      authorUrl: json['author_url'] as String? ?? '',
      type: json['type'] as String? ?? '',
      height: json['height'] as int? ?? 0,
      width: json['width'] as int? ?? 0,
      version: json['version'] as String? ?? '',
      providerName: json['provider_name'] as String? ?? '',
      providerUrl: json['provider_url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      thumbnailHeight: json['thumbnail_height'] as int? ?? 0,
      thumbnailWidth: json['thumbnail_width'] as int? ?? 0,
      html: json['html'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author_name': authorName,
      'author_url': authorUrl,
      'type': type,
      'height': height,
      'width': width,
      'version': version,
      'provider_name': providerName,
      'provider_url': providerUrl,
      'thumbnail_url': thumbnailUrl,
      'thumbnail_height': thumbnailHeight,
      'thumbnail_width': thumbnailWidth,
      'html': html,
    };
  }
}
