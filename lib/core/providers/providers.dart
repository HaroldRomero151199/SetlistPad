import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../clients/clients.dart';
import '../config/config.dart';
import '../services/services.dart';
import '../../features/songs/songs.dart';
import '../../features/playlists/playlists.dart';

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

// Hive Box Providers
final songBoxProvider = Provider<Box<Song>>((ref) {
  return Hive.box<Song>(HiveBoxes.songs);
});

final playlistBoxProvider = Provider<Box<Playlist>>((ref) {
  return Hive.box<Playlist>(HiveBoxes.playlists);
});

// Repository Providers (Injecting Boxes)
final songRepositoryProvider = Provider<SongRepository>((ref) {
  return HiveSongRepository(songBox: ref.watch(songBoxProvider));
});

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  return HivePlaylistRepository(playlistBox: ref.watch(playlistBoxProvider));
});
