import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:setlist_pad/core/clients/models/youtube_models.dart';
import 'package:setlist_pad/core/clients/youtube_client.dart';

void main() {
  group('YouTubeClient Tests', () {
    test('fetchOEmbedData returns YouTubeOembedResponse when status is 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/oembed');
        return http.Response(
          jsonEncode({
            'title': 'Coldplay - Yellow (Official Video)',
            'author_name': 'Coldplay',
            'thumbnail_url': 'https://example.com/thumb.jpg',
          }),
          200,
        );
      });

      final client = YouTubeClient(client: mockClient);
      final result = await client.fetchOEmbedData(
        const YouTubeOembedRequest(url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
      );

      expect(result.title, 'Coldplay - Yellow (Official Video)');
      expect(result.authorName, 'Coldplay');
      expect(result.thumbnailUrl, 'https://example.com/thumb.jpg');
    });

    test('fetchOEmbedData throws Exception when status is not 200', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Error', 400);
      });

      final client = YouTubeClient(client: mockClient);

      expect(
        () => client.fetchOEmbedData(
          const YouTubeOembedRequest(url: 'https://www.youtube.com/watch?v=invalid'),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
