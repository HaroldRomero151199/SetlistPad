import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../clients/clients.dart';
import '../services/services.dart';

// HTTP Clients Providers
final youtubeClientProvider = Provider<YouTubeClient>((ref) {
  return YouTubeClient();
});

final lrclibClientProvider = Provider<LrclibClient>((ref) {
  return LrclibClient();
});

// Domain Services Providers (Injecting Clients)
final youtubeServiceProvider = Provider<YouTubeService>((ref) {
  return YouTubeService(client: ref.watch(youtubeClientProvider));
});

final lyricsServiceProvider = Provider<LyricsService>((ref) {
  return LyricsService(client: ref.watch(lrclibClientProvider));
});
