import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:setlist_pad/core/clients/lyrics_ovh_client.dart';

void main() {
  group('LyricsOvhClient Tests', () {
    test('returns lyrics when API returns 200 with valid JSON', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('Coldplay/Yellow')) {
          return http.Response('{"lyrics": "Look at the stars\\nLook how they shine for you"}', 200);
        }
        return http.Response('{"error": "No lyrics found"}', 404);
      });

      final client = LyricsOvhClient(client: mockClient);
      final lyrics = await client.fetchLyrics(artist: 'Coldplay', title: 'Yellow');

      expect(lyrics, 'Look at the stars\nLook how they shine for you');
    });

    test('returns null when API returns 404', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error": "No lyrics found"}', 404);
      });

      final client = LyricsOvhClient(client: mockClient);
      final lyrics = await client.fetchLyrics(artist: 'Unknown', title: 'Unknown');

      expect(lyrics, isNull);
    });

    test('returns null for empty artist or title without making request', () async {
      final client = LyricsOvhClient();
      expect(await client.fetchLyrics(artist: '', title: 'Yellow'), isNull);
      expect(await client.fetchLyrics(artist: 'Coldplay', title: ''), isNull);
    });
  });
}
