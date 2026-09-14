/// Request parameters for exact lyrics matching in LRCLIB
class GetLyricsRequest {
  final String trackName;
  final String artistName;
  final String? albumName;
  final int? duration;

  const GetLyricsRequest({
    required this.trackName,
    required this.artistName,
    this.albumName,
    this.duration,
  });

  Map<String, String> toQueryParameters() {
    final params = <String, String>{
      'track_name': trackName,
      'artist_name': artistName,
    };
    if (albumName != null) {
      params['album_name'] = albumName!;
    }
    if (duration != null) {
      params['duration'] = duration.toString();
    }
    return params;
  }
}

/// Request parameters for searching lyrics in LRCLIB
class SearchLyricsRequest {
  final String query;

  const SearchLyricsRequest({
    required this.query,
  });

  Map<String, String> toQueryParameters() {
    return {
      'q': query,
    };
  }
}

/// Strongly-typed response model from LRCLIB API
class LrclibResponse {
  final int? id;
  final String? trackName;
  final String? artistName;
  final String? albumName;
  final double? duration;
  final bool instrumental;
  final String? plainLyrics;
  final String? syncedLyrics;

  const LrclibResponse({
    this.id,
    this.trackName,
    this.artistName,
    this.albumName,
    this.duration,
    this.instrumental = false,
    this.plainLyrics,
    this.syncedLyrics,
  });

  factory LrclibResponse.fromJson(Map<String, dynamic> json) {
    return LrclibResponse(
      id: json['id'] as int?,
      trackName: json['trackName'] as String?,
      artistName: json['artistName'] as String?,
      albumName: json['albumName'] as String?,
      duration: (json['duration'] as num?)?.toDouble(),
      instrumental: json['instrumental'] as bool? ?? false,
      plainLyrics: json['plainLyrics'] as String?,
      syncedLyrics: json['syncedLyrics'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'instrumental': instrumental,
    };
    if (id != null) data['id'] = id;
    if (trackName != null) data['trackName'] = trackName;
    if (artistName != null) data['artistName'] = artistName;
    if (albumName != null) data['albumName'] = albumName;
    if (duration != null) data['duration'] = duration;
    if (plainLyrics != null) data['plainLyrics'] = plainLyrics;
    if (syncedLyrics != null) data['syncedLyrics'] = syncedLyrics;
    return data;
  }
}
