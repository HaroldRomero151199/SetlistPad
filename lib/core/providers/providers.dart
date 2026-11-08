import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../clients/clients.dart';
import '../config/config.dart';
import '../services/services.dart';
import '../../features/songs/songs.dart';
import '../../features/playlists/playlists.dart';

// Hive Boxes Providers
final songBoxProvider = Provider<Box<Song>>((ref) {
  return Hive.box<Song>(HiveBoxes.songs);
});

final playlistBoxProvider = Provider<Box<Playlist>>((ref) {
  return Hive.box<Playlist>(HiveBoxes.playlists);
});

// HTTP Clients Providers
final youtubeClientProvider = Provider<YouTubeClient>((ref) {
  return YouTubeClient();
});

final lrclibClientProvider = Provider<LrclibClient>((ref) {
  return LrclibClient();
});

final lyricsOvhClientProvider = Provider<LyricsOvhClient>((ref) {
  return LyricsOvhClient();
});

final translationClientProvider = Provider<TranslationClient>((ref) {
  return TranslationClient();
});

final bilingualLyricsParserProvider = Provider<BilingualLyricsParser>((ref) {
  return const BilingualLyricsParser();
});

final translationCacheBoxProvider = Provider<Box<String>?>((ref) {
  if (Hive.isBoxOpen(HiveBoxes.translationsCache)) {
    return Hive.box<String>(HiveBoxes.translationsCache);
  }
  return null;
});

final candidateMatchScorerProvider = Provider<CandidateMatchScorer>((ref) {
  return const CandidateMatchScorer();
});

final trackTitleSanitizerProvider = Provider<TrackTitleSanitizer>((ref) {
  return const TrackTitleSanitizer();
});

// Domain Services Providers (Injecting Clients and Utilities)
final youtubeServiceProvider = Provider<YouTubeService>((ref) {
  return YouTubeService(
    client: ref.watch(youtubeClientProvider),
    sanitizer: ref.watch(trackTitleSanitizerProvider),
  );
});

final lyricsServiceProvider = Provider<LyricsService>((ref) {
  return LyricsService(
    lrclibClient: ref.watch(lrclibClientProvider),
    lyricsOvhClient: ref.watch(lyricsOvhClientProvider),
    matchScorer: ref.watch(candidateMatchScorerProvider),
    sanitizer: ref.watch(trackTitleSanitizerProvider),
  );
});

final translationServiceProvider = Provider<TranslationService>((ref) {
  return TranslationService(
    client: ref.watch(translationClientProvider),
    cacheBox: ref.watch(translationCacheBoxProvider),
    parser: ref.watch(bilingualLyricsParserProvider),
  );
});

final lyricsExportServiceProvider = Provider<LyricsExportService>((ref) {
  return LyricsExportService(
    parser: ref.watch(bilingualLyricsParserProvider),
  );
});
