import 'package:hive/hive.dart';
import '../../domain/models/song_model.dart';

abstract class SongRepository {
  Future<List<Song>> getAllSongs();
  Future<Song?> getSongById(String id);
  Future<void> saveSong(Song song);
  Future<void> deleteSong(String id);
  Future<List<Song>> searchSongs(String query);
}

class HiveSongRepository implements SongRepository {
  final Box<Song> songBox;

  HiveSongRepository({required this.songBox});

  @override
  Future<List<Song>> getAllSongs() async {
    return songBox.values.toList();
  }

  @override
  Future<Song?> getSongById(String id) async {
    return songBox.get(id);
  }

  @override
  Future<void> saveSong(Song song) async {
    await songBox.put(song.id, song);
  }

  @override
  Future<void> deleteSong(String id) async {
    await songBox.delete(id);
  }

  @override
  Future<List<Song>> searchSongs(String query) async {
    final lowerQuery = query.toLowerCase().trim();
    if (lowerQuery.isEmpty) return getAllSongs();

    return songBox.values.where((song) {
      return song.title.toLowerCase().contains(lowerQuery) ||
          song.artist.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
