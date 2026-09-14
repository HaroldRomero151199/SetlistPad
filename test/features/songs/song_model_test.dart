import 'package:flutter_test/flutter_test.dart';
import 'package:setlist_pad/features/songs/domain/models/song_model.dart';

void main() {
  group('Song Model Tests', () {
    test('toJson and fromJson should correctly serialize and deserialize', () {
      final now = DateTime.now();
      final song = Song(
        id: 'song-1',
        title: 'Yellow',
        artist: 'Coldplay',
        youtubeUrl: 'https://youtube.com/watch?v=123',
        lyrics: 'Look at the stars...',
        createdAt: now,
        updatedAt: now,
      );

      final jsonMap = song.toJson();
      expect(jsonMap['id'], 'song-1');
      expect(jsonMap['title'], 'Yellow');
      expect(jsonMap['artist'], 'Coldplay');

      final deserialized = Song.fromJson(jsonMap);
      expect(deserialized.id, song.id);
      expect(deserialized.title, song.title);
      expect(deserialized.artist, song.artist);
      expect(deserialized.lyrics, song.lyrics);
    });

    test('copyWith should clone song with updated attributes', () {
      final now = DateTime.now();
      final song = Song(
        id: 'song-1',
        title: 'Yellow',
        artist: 'Coldplay',
        youtubeUrl: 'https://youtube.com/watch?v=123',
        lyrics: 'Original lyrics',
        createdAt: now,
        updatedAt: now,
      );

      final updated = song.copyWith(lyrics: 'Updated lyrics');
      expect(updated.id, song.id);
      expect(updated.title, song.title);
      expect(updated.lyrics, 'Updated lyrics');
      expect(updated.youtubeUrl, 'https://youtube.com/watch?v=123');

      // Test clearing nullable youtubeUrl
      final cleared = song.copyWith(clearYoutubeUrl: true);
      expect(cleared.youtubeUrl, isNull);
    });
  });
}
