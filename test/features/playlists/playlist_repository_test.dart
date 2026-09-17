import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:setlist_pad/features/playlists/data/repositories/playlist_repository.dart';
import 'package:setlist_pad/features/playlists/domain/models/playlist_model.dart';

void main() {
  group('HivePlaylistRepository Tests', () {
    late Directory tempDir;
    late Box<Playlist> playlistBox;
    late HivePlaylistRepository repository;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_playlist_test_');
      Hive.init(tempDir.path);
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(PlaylistAdapter());
      }
      playlistBox = await Hive.openBox<Playlist>('test_playlists_box');
      repository = HivePlaylistRepository(playlistBox: playlistBox);
    });

    tearDown(() async {
      await playlistBox.close();
      await Hive.deleteBoxFromDisk('test_playlists_box');
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    Playlist makePlaylist({
      String id = 'pl-1',
      String name = 'Acoustic Set',
      String description = 'Chill acoustic songs for Sunday',
      List<String>? songIds,
    }) {
      return Playlist(
        id: id,
        name: name,
        description: description,
        songIds: songIds ?? ['song-1', 'song-2'],
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
    }

    test('getAllPlaylists should return empty list initially and all saved playlists', () async {
      expect(await repository.getAllPlaylists(), isEmpty);

      await repository.savePlaylist(makePlaylist(id: 'pl-1', name: 'Acoustic Set'));
      await repository.savePlaylist(makePlaylist(id: 'pl-2', name: 'Rock Night'));

      final playlists = await repository.getAllPlaylists();
      expect(playlists.length, 2);
      expect(playlists.map((p) => p.id), containsAll(['pl-1', 'pl-2']));
    });

    test('getPlaylistById should return playlist if exists, or null if not found', () async {
      await repository.savePlaylist(makePlaylist(id: 'pl-1', name: 'Acoustic Set'));

      final found = await repository.getPlaylistById('pl-1');
      expect(found, isNotNull);
      expect(found!.name, 'Acoustic Set');
      expect(found.songIds, ['song-1', 'song-2']);

      final notFound = await repository.getPlaylistById('non-existent');
      expect(notFound, isNull);
    });

    test('savePlaylist should insert or update existing playlist', () async {
      final initial = makePlaylist(id: 'pl-1', name: 'Acoustic Set');
      await repository.savePlaylist(initial);
      expect((await repository.getPlaylistById('pl-1'))!.name, 'Acoustic Set');

      final updated = initial.copyWith(name: 'Sunday Morning Acoustic');
      await repository.savePlaylist(updated);

      final result = await repository.getPlaylistById('pl-1');
      expect(result!.name, 'Sunday Morning Acoustic');
      expect((await repository.getAllPlaylists()).length, 1);
    });

    test('deletePlaylist should remove playlist from box', () async {
      await repository.savePlaylist(makePlaylist(id: 'pl-1'));
      await repository.savePlaylist(makePlaylist(id: 'pl-2'));
      expect((await repository.getAllPlaylists()).length, 2);

      await repository.deletePlaylist('pl-1');

      expect(await repository.getPlaylistById('pl-1'), isNull);
      expect((await repository.getAllPlaylists()).length, 1);
      expect((await repository.getAllPlaylists()).first.id, 'pl-2');
    });

    test('addSongToPlaylist should add new song without duplicates', () async {
      await repository.savePlaylist(makePlaylist(id: 'pl-1', songIds: ['song-1', 'song-2']));

      // Add new song
      await repository.addSongToPlaylist('pl-1', 'song-3');
      var updated = await repository.getPlaylistById('pl-1');
      expect(updated!.songIds, ['song-1', 'song-2', 'song-3']);

      // Attempt duplicate addition (should not duplicate)
      await repository.addSongToPlaylist('pl-1', 'song-3');
      updated = await repository.getPlaylistById('pl-1');
      expect(updated!.songIds, ['song-1', 'song-2', 'song-3']);

      // Adding to non-existent playlist should not crash
      await repository.addSongToPlaylist('non-existent', 'song-4');
    });

    test('removeSongFromPlaylist should remove song if present', () async {
      await repository.savePlaylist(makePlaylist(id: 'pl-1', songIds: ['song-1', 'song-2']));

      // Remove existing song
      await repository.removeSongFromPlaylist('pl-1', 'song-1');
      var updated = await repository.getPlaylistById('pl-1');
      expect(updated!.songIds, ['song-2']);

      // Remove non-present song does nothing harmful
      await repository.removeSongFromPlaylist('pl-1', 'song-999');
      updated = await repository.getPlaylistById('pl-1');
      expect(updated!.songIds, ['song-2']);

      // Removing from non-existent playlist should not crash
      await repository.removeSongFromPlaylist('non-existent', 'song-1');
    });

    test('removeSongFromAllPlaylists should remove song across multiple playlists', () async {
      await repository.savePlaylist(makePlaylist(id: 'pl-1', songIds: ['song-1', 'song-2']));
      await repository.savePlaylist(makePlaylist(id: 'pl-2', songIds: ['song-1', 'song-3']));
      await repository.savePlaylist(makePlaylist(id: 'pl-3', songIds: ['song-2', 'song-3']));

      await repository.removeSongFromAllPlaylists('song-1');

      final pl1 = await repository.getPlaylistById('pl-1');
      final pl2 = await repository.getPlaylistById('pl-2');
      final pl3 = await repository.getPlaylistById('pl-3');

      expect(pl1!.songIds, ['song-2']);
      expect(pl2!.songIds, ['song-3']);
      expect(pl3!.songIds, ['song-2', 'song-3']);
    });
  });
}
