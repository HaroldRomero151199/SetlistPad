import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:setlist_pad/core/clients/clients.dart';
import 'package:setlist_pad/core/services/lyrics_service.dart';

void main() {
  group('LyricsService Tests', () {
    test('cleanSyncedLyrics should strip LRC timestamps', () {
      final service = LyricsService();
      const synced = '[00:12.34]Look at the stars\n[00:15.67]Look how they shine for you';
      final cleaned = service.cleanSyncedLyrics(synced);
      expect(cleaned, 'Look at the stars\nLook how they shine for you');
    });

    test('fetches lyrics via LRCLIB exact match', () async {
      final mockHttp = MockClient((request) async {
        if (request.url.path.contains('/get')) {
          return http.Response(
            '{"id": 1, "trackName": "Yellow", "artistName": "Coldplay", "plainLyrics": "Look at the stars"}',
            200,
          );
        }
        return http.Response('', 404);
      });

      final service = LyricsService(
        lrclibClient: LrclibClient(client: mockHttp),
      );

      final lyrics = await service.fetchLyrics(title: 'Yellow', artist: 'Coldplay');
      expect(lyrics, 'Look at the stars');
    });

    test('falls back to LRCLIB candidate search and match scoring if exact match fails', () async {
      final mockHttp = MockClient((request) async {
        if (request.url.path.contains('/get')) {
          return http.Response('', 404);
        }
        if (request.url.path.contains('/search')) {
          return http.Response(
            '[{"id": 2, "trackName": "Making Love Out of Nothing at All", "artistName": "Air Supply", "plainLyrics": "I know just how to whisper"}]',
            200,
          );
        }
        return http.Response('', 404);
      });

      final service = LyricsService(
        lrclibClient: LrclibClient(client: mockHttp),
      );

      final lyrics = await service.fetchLyrics(
        title: 'Making Love Out of Nothing at All (Tour Concert)',
        artist: 'Air Supply',
      );
      expect(lyrics, 'I know just how to whisper');
    });

    test('falls back to Lyrics.ovh when LRCLIB returns no matches', () async {
      final mockLrclib = MockClient((request) async => http.Response('', 404));
      final mockOvh = MockClient((request) async {
        if (request.url.path.contains('Coldplay/Yellow')) {
          return http.Response('{"lyrics": "Look at the stars from OVH"}', 200);
        }
        return http.Response('', 404);
      });

      final service = LyricsService(
        lrclibClient: LrclibClient(client: mockLrclib),
        lyricsOvhClient: LyricsOvhClient(client: mockOvh),
      );

      final lyrics = await service.fetchLyrics(title: 'Yellow', artist: 'Coldplay');
      expect(lyrics, 'Look at the stars from OVH');
    });
  });
}
