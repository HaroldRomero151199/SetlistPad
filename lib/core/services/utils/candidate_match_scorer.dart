import '../../clients/lrclib/lrclib.dart';

/// Scores and ranks candidate search results based on similarity with query artist and track name.
class CandidateMatchScorer {
  const CandidateMatchScorer();

  /// Stop words ignored during token overlap matching
  static const Set<String> _stopWords = {
    'the', 'a', 'an', 'and', '&', 'of', 'in', 'on', 'at', 'to', 'for', 'with', 'by', 'feat', 'ft',
  };

  /// Computes a match score between [0.0, 1.0] comparing query with candidate metadata.
  double computeScore({
    required String queryArtist,
    required String queryTitle,
    required String candidateArtist,
    required String candidateTitle,
  }) {
    final normQueryArtist = _normalize(queryArtist);
    final normQueryTitle = _normalize(queryTitle);
    final normCandArtist = _normalize(candidateArtist);
    final normCandTitle = _normalize(candidateTitle);

    if (normQueryTitle.isEmpty || normCandTitle.isEmpty) return 0.0;

    final titleScore = _similarity(normQueryTitle, normCandTitle);

    // If query artist is unknown, score relies solely on title similarity
    final isUnknownArtist = normQueryArtist.isEmpty ||
        normQueryArtist == 'unknown artist' ||
        normQueryArtist == 'unknown';

    if (isUnknownArtist) {
      return titleScore;
    }

    final artistScore = _similarity(normQueryArtist, normCandArtist);

    // Weighted composite score: 45% artist, 55% title
    return (artistScore * 0.45) + (titleScore * 0.55);
  }

  /// Returns the highest-ranking candidate from [candidates] that has lyrics and meets [minThreshold].
  LrclibResponse? findBestMatch({
    required String queryArtist,
    required String queryTitle,
    required List<LrclibResponse> candidates,
    double minThreshold = 0.50,
  }) {
    LrclibResponse? bestCandidate;
    double highestScore = -1.0;

    for (final candidate in candidates) {
      final plain = candidate.plainLyrics?.trim();
      final synced = candidate.syncedLyrics?.trim();
      if ((plain == null || plain.isEmpty) && (synced == null || synced.isEmpty)) {
        continue;
      }

      final candArtist = candidate.artistName ?? '';
      final candTitle = candidate.trackName ?? '';

      final score = computeScore(
        queryArtist: queryArtist,
        queryTitle: queryTitle,
        candidateArtist: candArtist,
        candidateTitle: candTitle,
      );

      if (score >= minThreshold && score > highestScore) {
        highestScore = score;
        bestCandidate = candidate;
      }
    }

    return bestCandidate;
  }

  /// Normalizes string: lowercases, strips punctuation, normalizes spaces
  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Calculates text similarity using exact match, containment, and token overlap
  double _similarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    // Substring containment gives a very strong score
    if (a.contains(b) || b.contains(a)) {
      final minLen = a.length < b.length ? a.length : b.length;
      final maxLen = a.length > b.length ? a.length : b.length;
      return 0.85 + (0.15 * (minLen / maxLen));
    }

    // Token overlap comparison (Jaccard similarity on non-stop words)
    final tokensA = a.split(' ').where((t) => t.isNotEmpty && !_stopWords.contains(t)).toSet();
    final tokensB = b.split(' ').where((t) => t.isNotEmpty && !_stopWords.contains(t)).toSet();

    if (tokensA.isEmpty || tokensB.isEmpty) {
      return 0.0;
    }

    final intersection = tokensA.intersection(tokensB).length;
    final union = tokensA.union(tokensB).length;

    if (union == 0) return 0.0;
    return intersection / union;
  }
}
