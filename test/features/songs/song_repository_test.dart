import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:setlist_pad/features/songs/data/repositories/song_repository.dart';
import 'package:setlist_pad/features/songs/domain/models/song_model.dart';

void main() {
  group('HiveSongRepository Tests', () {
    late Directory tempDir;
    late Box<Song> songBox;
    late HiveSongRepository repository;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_song_test_');
      Hive.init(tempDir.path);
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(SongAdapter());
      }
      songBox = await Hive.openBox<Song>('test_songs_box');
      repository = HiveSongRepository(songBox: songBox);
    });

    tearDown(() async {
      await songBox.close();
      await Hive.deleteBoxFromDisk('test_songs_box');
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    Song makeSong({
      String id = 'song-1',
      String title = 'Yellow',
      String artist = 'Coldplay',
      String? youtubeUrl = 'https://youtube.com/watch?v=123',
      String lyrics = 'Look at the stars',
    }) {
      return Song(
        id: id,
        title: title,
        artist: artist,
        youtubeUrl: youtubeUrl,
        lyrics: lyrics,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
    }

    test('getAllSongs should return empty list initially and all songs once saved', () async {
      expect(await repository.getAllSongs(), isEmpty);

      await repository.saveSong(makeSong(id: 'song-1', title: 'Yellow'));
      await repository.saveSong(makeSong(id: 'song-2', title: 'Fix You'));

      final songs = await repository.getAllSongs();
      expect(songs.length, 2);
      expect(songs.map((s) => s.id), containsAll(['song-1', 'song-2']));
    });

    test('getSongById should return song if exists, or null if not found', () async {
      await repository.saveSong(makeSong(id: 'song-1', title: 'Yellow', artist: 'Coldplay'));

      final found = await repository.getSongById('song-1');
      expect(found, isNotNull);
      expect(found!.title, 'Yellow');
      expect(found.artist, 'Coldplay');

      final notFound = await repository.getSongById('non-existent');
      expect(notFound, isNull);
    });

    test('saveSong should insert or update existing song', () async {
      final song = makeSong(id: 'song-1', lyrics: 'Look at the stars');
      await repository.saveSong(song);
      expect((await repository.getSongById('song-1'))!.lyrics, 'Look at the stars');

      final updatedSong = song.copyWith(lyrics: 'Updated lyrics');
      await repository.saveSong(updatedSong);

      final result = await repository.getSongById('song-1');
      expect(result!.lyrics, 'Updated lyrics');
      expect((await repository.getAllSongs()).length, 1);
    });

    test('deleteSong should remove song from box', () async {
      await repository.saveSong(makeSong(id: 'song-1'));
      await repository.saveSong(makeSong(id: 'song-2'));
      expect((await repository.getAllSongs()).length, 2);

      await repository.deleteSong('song-1');

      expect(await repository.getSongById('song-1'), isNull);
      expect((await repository.getAllSongs()).length, 1);
      expect((await repository.getAllSongs()).first.id, 'song-2');
    });

    test('searchSongs should filter by title or artist case-insensitively', () async {
      await repository.saveSong(makeSong(id: 'song-1', title: 'Yellow', artist: 'Coldplay'));
      await repository.saveSong(makeSong(id: 'song-2', title: 'Fix You', artist: 'Coldplay'));
      await repository.saveSong(makeSong(id: 'song-3', title: 'Bohemian Rhapsody', artist: 'Queen'));

      // Search by artist (matches 2 songs)
      final coldplaySongs = await repository.searchSongs('coldplay');
      expect(coldplaySongs.length, 2);
      expect(coldplaySongs.map((s) => s.id), containsAll(['song-1', 'song-2']));

      // Search by title
      final yellowSongs = await repository.searchSongs('yellow');
      expect(yellowSongs.length, 1);
      expect(yellowSongs.first.id, 'song-1');

      // Empty query returns all songs
      final allSongs = await repository.searchSongs('   ');
      expect(allSongs.length, 3);

      // Non-matching query
      final noResults = await repository.searchSongs('oasis');
      expect(noResults, isEmpty);
    });
  });
}
