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
