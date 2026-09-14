import 'package:hive/hive.dart';
import '../../domain/models/playlist_model.dart';

abstract class PlaylistRepository {
  Future<List<Playlist>> getAllPlaylists();
  Future<Playlist?> getPlaylistById(String id);
  Future<void> savePlaylist(Playlist playlist);
  Future<void> deletePlaylist(String id);
  Future<void> addSongToPlaylist(String playlistId, String songId);
  Future<void> removeSongFromPlaylist(String playlistId, String songId);
}

class HivePlaylistRepository implements PlaylistRepository {
  final Box<Playlist> playlistBox;

  HivePlaylistRepository({required this.playlistBox});

  @override
  Future<List<Playlist>> getAllPlaylists() async {
    return playlistBox.values.toList();
  }

  @override
  Future<Playlist?> getPlaylistById(String id) async {
    return playlistBox.get(id);
  }

  @override
  Future<void> savePlaylist(Playlist playlist) async {
    await playlistBox.put(playlist.id, playlist);
  }

  @override
  Future<void> deletePlaylist(String id) async {
    await playlistBox.delete(id);
  }

  @override
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final playlist = playlistBox.get(playlistId);
    if (playlist != null) {
      if (!playlist.songIds.contains(songId)) {
        final updatedSongs = List<String>.from(playlist.songIds)..add(songId);
        final updatedPlaylist = playlist.copyWith(
          songIds: updatedSongs,
          updatedAt: DateTime.now(),
        );
        await playlistBox.put(playlistId, updatedPlaylist);
      }
    }
  }

  @override
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final playlist = playlistBox.get(playlistId);
    if (playlist != null) {
      final updatedSongs = List<String>.from(playlist.songIds)..remove(songId);
      final updatedPlaylist = playlist.copyWith(
        songIds: updatedSongs,
        updatedAt: DateTime.now(),
      );
      await playlistBox.put(playlistId, updatedPlaylist);
    }
  }
}
