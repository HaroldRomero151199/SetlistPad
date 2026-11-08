import 'package:setlist_pad/features/songs/songs.dart';

/// Test double for SongRepository
class FakeSongRepository implements SongRepository {
  final List<Song> _songs = [];

  @override
  Future<void> deleteSong(String id) async {
    _songs.removeWhere((s) => s.id == id);
  }

  @override
  Future<List<Song>> getAllSongs() async => List.unmodifiable(_songs);

  @override
  Future<Song?> getSongById(String id) async {
    try {
      return _songs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveSong(Song song) async {
    final index = _songs.indexWhere((s) => s.id == song.id);
    if (index >= 0) {
      _songs[index] = song;
    } else {
      _songs.add(song);
    }
  }

  @override
  Future<List<Song>> searchSongs(String query) async {
    final q = query.toLowerCase();
    return _songs
        .where(
          (s) =>
              s.title.toLowerCase().contains(q) ||
              s.artist.toLowerCase().contains(q),
        )
        .toList();
  }
}

