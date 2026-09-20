import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:setlist_pad/core/clients/youtube_client.dart';
import 'package:setlist_pad/core/services/youtube_service.dart';

void main() {
  group('YouTubeService Tests', () {
    late YouTubeService service;

    setUp(() {
      service = YouTubeService();
    });

    test('extractVideoId should correctly parse various YouTube URL formats including shorts and live', () {
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
      expect(
        service.extractVideoId('https://www.youtube.com/shorts/dQw4w9WgXcQ'),
        'dQw4w9WgXcQ',
      );
      expect(
        service.extractVideoId('https://www.youtube.com/live/dQw4w9WgXcQ?feature=share'),
        'dQw4w9WgXcQ',
      );
    });

    test('extractPlaylistId should correctly parse playlist URLs including extra query parameters like si', () {
      expect(
        service.extractPlaylistId('https://www.youtube.com/playlist?list=PL4fGSI1pDJn6jWpXK5A8k68Wp9Z2yK_b3'),
        'PL4fGSI1pDJn6jWpXK5A8k68Wp9Z2yK_b3',
      );
      expect(
        service.extractPlaylistId('https://youtube.com/playlist?list=PLJrsDt9Np1u8&si=wqbOAShbE97cXg_g'),
        'PLJrsDt9Np1u8',
      );
      expect(
        service.extractPlaylistId('https://www.youtube.com/watch?v=abc12345678&list=PL4fGSI1pDJn6jWpXK5A8k68Wp9Z2yK_b3'),
        'PL4fGSI1pDJn6jWpXK5A8k68Wp9Z2yK_b3',
      );
    });

    test('isPlaylistUrl correctly identifies playlist vs video URLs', () {
      expect(
        service.isPlaylistUrl('https://youtube.com/playlist?list=PLJrsDt9Np1u8&si=wqbOAShbE97cXg_g'),
        isTrue,
      );
      expect(
        service.isPlaylistUrl('https://www.youtube.com/playlist?list=PL4fGSI1pDJn6jWpXK5A8k68Wp9Z2yK_b3'),
        isTrue,
      );
      expect(
        service.isPlaylistUrl('https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
        isFalse,
      );
      expect(
        service.isPlaylistUrl('https://youtu.be/dQw4w9WgXcQ'),
        isFalse,
      );
    });

    test('fetchPlaylistMetadata extracts and cleans playlist items', () async {
      const atomXml = '''<?xml version="1.0" encoding="UTF-8"?>
      <feed xmlns="http://www.w3.org/2005/Atom" xmlns:yt="http://www.youtube.com/xml/schemas/2015" xmlns:media="http://search.yahoo.com/mrss/">
        <title>Acoustic Session</title>
        <author><name>Harold</name></author>
        <entry>
          <yt:videoId>track111111</yt:videoId>
          <media:title>Coldplay - The Scientist (Official Video)</media:title>
          <author><name>ColdplayVEVO</name></author>
        </entry>
        <entry>
          <yt:videoId>track222222</yt:videoId>
          <media:title>Oasis - Wonderwall</media:title>
          <author><name>Oasis</name></author>
        </entry>
      </feed>
      ''';

      final mockClient = MockClient((request) async {
        if (request.url.path.contains('videos.xml')) {
          return http.Response(atomXml, 200);
        }
        return http.Response('', 404);
      });

      final customService = YouTubeService(client: YouTubeClient(client: mockClient));
      final metadata = await customService.fetchPlaylistMetadata(
        'https://youtube.com/playlist?list=PLAcoustic123&si=test_si',
      );

      expect(metadata.id, 'PLAcoustic123');
      expect(metadata.title, 'Acoustic Session');
      expect(metadata.items.length, 2);

      expect(metadata.items[0].videoId, 'track111111');
      expect(metadata.items[0].title, 'The Scientist');
      expect(metadata.items[0].artist, 'Coldplay');

      expect(metadata.items[1].videoId, 'track222222');
      expect(metadata.items[1].title, 'Wonderwall');
      expect(metadata.items[1].artist, 'Oasis');
    });

    test('fetchPlaylistMetadata throws FormatException on invalid URL', () async {
      expect(
        () => service.fetchPlaylistMetadata('https://example.com/not_youtube'),
        throwsA(isA<FormatException>()),
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

    test('parseTitleAndArtist preserves hyphenated artist names and song titles', () {
      final res1 = service.parseTitleAndArtist('Jay-Z - Empire State of Mind', 'JayZVEVO');
      expect(res1['artist'], 'Jay-Z');
      expect(res1['title'], 'Empire State of Mind');

      final res2 = service.parseTitleAndArtist('Blink-182 - All the Small Things (Official Video)', 'Blink182VEVO');
      expect(res2['artist'], 'Blink-182');
      expect(res2['title'], 'All the Small Things');

      final res3 = service.parseTitleAndArtist('Anti-Hero', 'Taylor Swift');
      expect(res3['artist'], 'Taylor Swift');
      expect(res3['title'], 'Anti-Hero');
    });
  });
}
