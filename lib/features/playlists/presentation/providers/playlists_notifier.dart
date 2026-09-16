import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/providers/providers.dart';
import '../../playlists.dart';

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  final box = ref.watch(playlistBoxProvider);
  return HivePlaylistRepository(playlistBox: box);
});

class PlaylistsNotifier extends Notifier<AsyncValue<List<Playlist>>> {
  final PlaylistRepository? _repository;

  PlaylistsNotifier({PlaylistRepository? repository}) : _repository = repository;

  PlaylistRepository get repository =>
      _repository ?? ref.read(playlistRepositoryProvider);

  @override
  AsyncValue<List<Playlist>> get state => super.state;

  @override
  AsyncValue<List<Playlist>> build() {
    loadPlaylists();
    return const AsyncValue.loading();
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

final playlistsNotifierProvider =
    NotifierProvider<PlaylistsNotifier, AsyncValue<List<Playlist>>>(
  PlaylistsNotifier.new,
);
