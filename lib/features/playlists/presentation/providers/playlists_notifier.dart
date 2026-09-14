import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/providers/providers.dart';
import '../../playlists.dart';

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  final box = ref.watch(playlistBoxProvider);
  return HivePlaylistRepository(playlistBox: box);
});

final playlistsNotifierProvider =
    StateNotifierProvider<PlaylistsNotifier, AsyncValue<List<Playlist>>>((ref) {
  final repository = ref.watch(playlistRepositoryProvider);
  return PlaylistsNotifier(repository: repository);
});

class PlaylistsNotifier extends StateNotifier<AsyncValue<List<Playlist>>> {
  final PlaylistRepository repository;

  PlaylistsNotifier({required this.repository})
      : super(const AsyncValue.loading()) {
    loadPlaylists();
  }

  Future<void> loadPlaylists() async {
    try {
      final playlists = await repository.getAllPlaylists();
      state = AsyncValue.data(playlists);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Playlist> createPlaylist({
    required String name,
    String description = '',
    String? youtubePlaylistUrl,
    List<String> songIds = const [],
  }) async {
    final now = DateTime.now();
    final newPlaylist = Playlist(
      id: const Uuid().v4(),
      name: name,
      description: description,
      youtubePlaylistUrl: youtubePlaylistUrl,
      songIds: songIds,
      createdAt: now,
      updatedAt: now,
    );

    await repository.savePlaylist(newPlaylist);
    await loadPlaylists();
    return newPlaylist;
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    await repository.addSongToPlaylist(playlistId, songId);
    await loadPlaylists();
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    await repository.removeSongFromPlaylist(playlistId, songId);
    await loadPlaylists();
  }

  Future<void> deletePlaylist(String playlistId) async {
    await repository.deletePlaylist(playlistId);
    await loadPlaylists();
  }
}
