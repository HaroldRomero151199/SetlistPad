import 'package:flutter_test/flutter_test.dart';
import 'package:setlist_pad/core/services/youtube_service.dart';

void main() {
  group('YouTubeService Tests', () {
    late YouTubeService service;

    setUp(() {
      service = YouTubeService();
    });

    test('extractVideoId should correctly parse various YouTube URL formats', () {
      expect(
        service.extractVideoId('https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
        'dQw4w9WgXcQ',
      );
      expect(
        service.extractVideoId('https://youtu.be/dQw4w9WgXcQ'),
        'dQw4w9WgXcQ',
      );
      expect(
        service.extractVideoId('https://www.youtube.com/embed/dQw4w9WgXcQ'),
        'dQw4w9WgXcQ',
      );
      expect(
        service.extractVideoId('https://m.youtube.com/watch?v=dQw4w9WgXcQ&t=30s'),
        'dQw4w9WgXcQ',
      );
    });

    test('extractPlaylistId should correctly parse playlist URLs', () {
      expect(
        service.extractPlaylistId('https://www.youtube.com/playlist?list=PL4fGSI1pDJn6jWpXK5A8k68Wp9Z2yK_b3'),
        'PL4fGSI1pDJn6jWpXK5A8k68Wp9Z2yK_b3',
      );
      expect(
        service.extractPlaylistId('https://www.youtube.com/watch?v=abc12345678&list=PL4fGSI1pDJn6jWpXK5A8k68Wp9Z2yK_b3'),
        'PL4fGSI1pDJn6jWpXK5A8k68Wp9Z2yK_b3',
      );
    });

    test('parseTitleAndArtist should clean titles with dashes and official video tags', () {
      final res1 = service.parseTitleAndArtist('Coldplay - Yellow (Official Video)', 'ColdplayVEVO');
      expect(res1['artist'], 'Coldplay');
      expect(res1['title'], 'Yellow');

      final res2 = service.parseTitleAndArtist('Bohemian Rhapsody (Lyric Video)', 'Queen');
      expect(res2['artist'], 'Queen');
      expect(res2['title'], 'Bohemian Rhapsody');
    });
  });
}
