/// Response model from Lyrics.ovh API
class LyricsOvhResponse {
  final String lyrics;

  const LyricsOvhResponse({required this.lyrics});

  factory LyricsOvhResponse.fromJson(Map<String, dynamic> json) {
    return LyricsOvhResponse(
      lyrics: (json['lyrics'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lyrics': lyrics,
    };
  }
}
