import '../clients/clients.dart';
import 'utils/candidate_match_scorer.dart';
import 'utils/track_title_sanitizer.dart';

class LyricsService {
  final LrclibClient lrclibClient;
  final LyricsOvhClient lyricsOvhClient;
  final CandidateMatchScorer matchScorer;
  final TrackTitleSanitizer sanitizer;

  LyricsService({
    LrclibClient? client,
    LrclibClient? lrclibClient,
    LyricsOvhClient? lyricsOvhClient,
    CandidateMatchScorer? matchScorer,
    TrackTitleSanitizer? sanitizer,
  })  : lrclibClient = lrclibClient ?? client ?? LrclibClient(),
        lyricsOvhClient = lyricsOvhClient ?? LyricsOvhClient(),
        matchScorer = matchScorer ?? const CandidateMatchScorer(),
        sanitizer = sanitizer ?? const TrackTitleSanitizer();

  LrclibClient get client => lrclibClient;

  /// Fetches lyrics using multi-tier strategy with candidate relevance scoring and fallback provider
  Future<String?> fetchLyrics({required String title, required String artist}) async {
    final cleanTitle = sanitizer.cleanTitle(title);
    final cleanArtist = sanitizer.cleanArtistName(artist);

    // Tier 1: Try LRCLIB exact match with sanitized parameters
    final exactMatch = await lrclibClient.getLyrics(
      GetLyricsRequest(
        trackName: cleanTitle,
        artistName: cleanArtist,
      ),
    );

    if (exactMatch != null) {
      final extracted = _extractLyricsText(exactMatch);
      if (extracted != null) return extracted;
    }

    // Tier 2: Search LRCLIB specifically by track_name & artist_name and score candidates
    final isUnknownArtist = cleanArtist == 'Unknown Artist';
    final fieldCandidates = await lrclibClient.searchLyrics(
      SearchLyricsRequest(
        trackName: cleanTitle,
        artistName: isUnknownArtist ? null : cleanArtist,
      ),
    );

    if (fieldCandidates.isNotEmpty) {
      final bestMatch = matchScorer.findBestMatch(
        queryArtist: cleanArtist,
        queryTitle: cleanTitle,
        candidates: fieldCandidates,
      );
      if (bestMatch != null) {
        final extracted = _extractLyricsText(bestMatch);
        if (extracted != null) return extracted;
      }
    }

    // Tier 3: Search LRCLIB with general query and score candidates
    final query = isUnknownArtist ? cleanTitle : '$cleanArtist $cleanTitle';
    final queryCandidates = await lrclibClient.searchLyrics(
      SearchLyricsRequest(query: query),
    );

    if (queryCandidates.isNotEmpty) {
      final bestMatch = matchScorer.findBestMatch(
        queryArtist: cleanArtist,
        queryTitle: cleanTitle,
        candidates: queryCandidates,
      );
      if (bestMatch != null) {
        final extracted = _extractLyricsText(bestMatch);
        if (extracted != null) return extracted;
      }
    }

    // Tier 4: Fallback to open source Lyrics.ovh API
    if (!isUnknownArtist) {
      final ovhLyrics = await lyricsOvhClient.fetchLyrics(
        artist: cleanArtist,
        title: cleanTitle,
      );
      if (ovhLyrics != null && ovhLyrics.trim().isNotEmpty) {
        return ovhLyrics.trim();
      }
    }

    return null;
  }

  String? _extractLyricsText(LrclibResponse response) {
    final plain = response.plainLyrics?.trim();
    if (plain != null && plain.isNotEmpty) {
      return plain;
    }
    final synced = response.syncedLyrics?.trim();
    if (synced != null && synced.isNotEmpty) {
      return cleanSyncedLyrics(synced);
    }
    return null;
  }

  /// Removes timestamps from synced LRC lyrics (e.g. [00:12.34] -> text)
  String cleanSyncedLyrics(String syncedLyrics) {
    return syncedLyrics
        .replaceAll(RegExp(r'\[\d{2}:\d{2}\.\d{2,3}\]'), '')
        .trim();
  }
}
