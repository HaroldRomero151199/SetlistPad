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
