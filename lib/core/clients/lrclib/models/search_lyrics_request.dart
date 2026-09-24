/// Request parameters for searching lyrics in LRCLIB
class SearchLyricsRequest {
  final String? query;
  final String? trackName;
  final String? artistName;

  const SearchLyricsRequest({
    this.query,
    this.trackName,
    this.artistName,
  });

  Map<String, String> toQueryParameters() {
    final params = <String, String>{};
    if (query != null && query!.trim().isNotEmpty) {
      params['q'] = query!.trim();
    }
    if (trackName != null && trackName!.trim().isNotEmpty) {
      params['track_name'] = trackName!.trim();
    }
    if (artistName != null && artistName!.trim().isNotEmpty) {
      params['artist_name'] = artistName!.trim();
    }
    return params;
  }
}
