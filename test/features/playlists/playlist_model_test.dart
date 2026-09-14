import 'package:flutter_test/flutter_test.dart';
import 'package:setlist_pad/features/playlists/domain/models/playlist_model.dart';

void main() {
  group('Playlist Model Tests', () {
    test('toJson and fromJson should correctly serialize and deserialize playlist', () {
      final now = DateTime.now();
      final playlist = Playlist(
        id: 'pl-1',
        name: 'Rock Classics',
        description: 'Best 80s rock songs',
        youtubePlaylistUrl: 'https://youtube.com/playlist?list=123',
        songIds: ['song-1', 'song-2'],
        createdAt: now,
        updatedAt: now,
      );

      final jsonMap = playlist.toJson();
      expect(jsonMap['id'], 'pl-1');
      expect(jsonMap['name'], 'Rock Classics');
      expect(jsonMap['songIds'], ['song-1', 'song-2']);

      final deserialized = Playlist.fromJson(jsonMap);
      expect(deserialized.id, playlist.id);
      expect(deserialized.name, playlist.name);
      expect(deserialized.songIds, playlist.songIds);
    });

    test('copyWith should clone playlist with updated song list or clear youtubePlaylistUrl', () {
      final now = DateTime.now();
      final playlist = Playlist(
        id: 'pl-1',
        name: 'Rock Classics',
        youtubePlaylistUrl: 'https://youtube.com/playlist?list=123',
        songIds: ['song-1'],
        createdAt: now,
        updatedAt: now,
      );

      final updated = playlist.copyWith(songIds: ['song-1', 'song-2']);
      expect(updated.songIds, ['song-1', 'song-2']);
      expect(updated.youtubePlaylistUrl, 'https://youtube.com/playlist?list=123');

      // Test clearing nullable youtubePlaylistUrl
      final cleared = playlist.copyWith(clearYoutubePlaylistUrl: true);
      expect(cleared.youtubePlaylistUrl, isNull);
    });
  });
}
