import '../clients/lrclib_client.dart';
import '../clients/models/lrclib_models.dart';

class LyricsService {
  final LrclibClient client;

  LyricsService({LrclibClient? client}) : client = client ?? LrclibClient();

  /// Fetches lyrics from LRCLIB open source API by track title and artist
  Future<String?> fetchLyrics({required String title, required String artist}) async {
    final exactMatch = await client.getLyrics(
      GetLyricsRequest(
        trackName: title,
        artistName: artist,
      ),
    );

    if (exactMatch != null) {
      final plainLyrics = exactMatch.plainLyrics;
      if (plainLyrics != null && plainLyrics.trim().isNotEmpty) {
        return plainLyrics.trim();
      }
      final syncedLyrics = exactMatch.syncedLyrics;
      if (syncedLyrics != null && syncedLyrics.trim().isNotEmpty) {
        return cleanSyncedLyrics(syncedLyrics);
      }
    }

    return _searchLyrics(title: title, artist: artist);
  }

  Future<String?> _searchLyrics({required String title, required String artist}) async {
    final results = await client.searchLyrics(
      SearchLyricsRequest(
        query: '$artist $title',
      ),
    );

    for (final item in results) {
      final plain = item.plainLyrics;
      if (plain != null && plain.trim().isNotEmpty) {
        return plain.trim();
      }
      final synced = item.syncedLyrics;
      if (synced != null && synced.trim().isNotEmpty) {
        return cleanSyncedLyrics(synced);
      }
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
