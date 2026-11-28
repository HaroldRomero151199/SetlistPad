import 'package:setlist_pad/features/playlists/playlists.dart';

/// Test double for [PlaylistRepository].
class FakePlaylistRepository implements PlaylistRepository {
  final List<Playlist> _playlists = [];

  @override
  Future<List<Playlist>> getAllPlaylists() async =>
      List.unmodifiable(_playlists);

  @override
  Future<Playlist?> getPlaylistById(String id) async {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> savePlaylist(Playlist playlist) async {
    _playlists.removeWhere((p) => p.id == playlist.id);
    _playlists.add(playlist);
  }

  @override
  Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((p) => p.id == id);
  }

  @override
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final pl = await getPlaylistById(playlistId);
    if (pl != null && !pl.songIds.contains(songId)) {
      await savePlaylist(pl.copyWith(songIds: [...pl.songIds, songId]));
    }
  }

  @override
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final pl = await getPlaylistById(playlistId);
    if (pl != null) {
      final list = List<String>.from(pl.songIds)..remove(songId);
      await savePlaylist(pl.copyWith(songIds: list));
    }
  }

  @override
  Future<void> removeSongFromAllPlaylists(String songId) async {
    for (int i = 0; i < _playlists.length; i++) {
      if (_playlists[i].songIds.contains(songId)) {
        final list = List<String>.from(_playlists[i].songIds)..remove(songId);
        _playlists[i] = _playlists[i].copyWith(songIds: list);
      }
    }
  }
}
