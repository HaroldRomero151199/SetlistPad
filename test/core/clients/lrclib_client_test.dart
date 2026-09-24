import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:setlist_pad/core/clients/clients.dart';

void main() {
  group('LrclibClient Tests', () {
    test('getLyrics returns data when status is 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/get');
        expect(request.url.queryParameters['track_name'], 'Yellow');
        expect(request.url.queryParameters['artist_name'], 'Coldplay');
        return http.Response(
          jsonEncode({
            'plainLyrics': 'Look at the stars',
            'syncedLyrics': '[00:10.00]Look at the stars',
          }),
          200,
        );
      });

      final client = LrclibClient(client: mockClient);
      final result = await client.getLyrics(
        const GetLyricsRequest(trackName: 'Yellow', artistName: 'Coldplay'),
      );

      expect(result, isNotNull);
      expect(result!.plainLyrics, 'Look at the stars');
      expect(result.syncedLyrics, '[00:10.00]Look at the stars');
    });

    test('getLyrics returns null on non-200 status', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final client = LrclibClient(client: mockClient);
      final result = await client.getLyrics(
        const GetLyricsRequest(trackName: 'Unknown', artistName: 'Unknown'),
      );

      expect(result, isNull);
    });

    test('searchLyrics returns list of matches when status is 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/search');
        expect(request.url.queryParameters['q'], 'Coldplay Yellow');
        return http.Response(
          jsonEncode([
            {'id': 1, 'plainLyrics': 'Look at the stars'},
          ]),
          200,
        );
      });

      final client = LrclibClient(client: mockClient);
      final results = await client.searchLyrics(
        const SearchLyricsRequest(query: 'Coldplay Yellow'),
      );

      expect(results.length, 1);
      expect(results.first.id, 1);
      expect(results.first.plainLyrics, 'Look at the stars');
    });
  });
}
