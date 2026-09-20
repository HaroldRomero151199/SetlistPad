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

    test('fetchPlaylistData extracts tracks from ytInitialData web page HTML', () async {
      final sampleHtml = '''
      <!DOCTYPE html>
      <html>
      <body>
        <script>
          var ytInitialData = {
            "header": {
              "playlistHeaderRenderer": {
                "title": {"simpleText": "My Live Setlist"},
                "ownerText": {"runs": [{"text": "RockBand"}]}
              }
            },
            "contents": {
              "twoColumnBrowseResultsRenderer": {
                "tabs": [{
                  "tabRenderer": {
                    "content": {
                      "sectionListRenderer": {
                        "contents": [{
                          "itemSectionRenderer": {
                            "contents": [{
                              "playlistVideoListRenderer": {
                                "contents": [
                                  {
                                    "playlistVideoRenderer": {
                                      "videoId": "vid12345678",
                                      "title": {"runs": [{"text": "Queen - Radio Ga Ga"}]},
                                      "shortBylineText": {"runs": [{"text": "Queen"}]},
                                      "thumbnail": {
                                        "thumbnails": [{"url": "https://i.ytimg.com/vi/vid12345678/hqdefault.jpg"}]
                                      }
                                    }
                                  },
                                  {
                                    "playlistVideoRenderer": {
                                      "videoId": "vid87654321",
                                      "title": {"simpleText": "U2 - With or Without You"},
                                      "shortBylineText": {"runs": [{"text": "U2"}]}
                                    }
                                  }
                                ]
                              }
                            }]
                          }
                        }]
                      }
                    }
                  }
                }]
              }
            }
          };
        </script>
      </body>
      </html>
      ''';

      final mockClient = MockClient((request) async {
        if (request.url.path == '/playlist') {
          return http.Response(sampleHtml, 200);
        }
        return http.Response('Not Found', 404);
      });

      final client = YouTubeClient(client: mockClient);
      final response = await client.fetchPlaylistData(
        const YouTubePlaylistRequest(playlistId: 'PLTest123'),
      );

      expect(response.playlistId, 'PLTest123');
      expect(response.title, 'My Live Setlist');
      expect(response.author, 'RockBand');
      expect(response.tracks.length, 2);
      expect(response.tracks[0].videoId, 'vid12345678');
      expect(response.tracks[0].title, 'Queen - Radio Ga Ga');
      expect(response.tracks[0].author, 'Queen');
      expect(response.tracks[0].thumbnailUrl, 'https://i.ytimg.com/vi/vid12345678/hqdefault.jpg');
      expect(response.tracks[1].videoId, 'vid87654321');
      expect(response.tracks[1].title, 'U2 - With or Without You');
    });

    test('fetchPlaylistData falls back to Atom XML feed when web page lacks ytInitialData', () async {
      const atomXml = '''<?xml version="1.0" encoding="UTF-8"?>
      <feed xmlns="http://www.w3.org/2005/Atom" xmlns:yt="http://www.youtube.com/xml/schemas/2015" xmlns:media="http://search.yahoo.com/mrss/">
        <title>Fallback Playlist Title</title>
        <author><name>Harold</name></author>
        <entry>
          <yt:videoId>xmlVid12345</yt:videoId>
          <media:title>Bon Jovi - Livin on a Prayer</media:title>
          <author><name>Bon Jovi</name></author>
          <media:group>
            <media:thumbnail url="https://i.ytimg.com/vi/xmlVid12345/hqdefault.jpg"/>
          </media:group>
        </entry>
      </feed>
      ''';

      final mockClient = MockClient((request) async {
        if (request.url.path == '/playlist') {
          return http.Response('<html><body>Blocked / Bot Check</body></html>', 200);
        }
        if (request.url.path.contains('videos.xml')) {
          return http.Response(atomXml, 200);
        }
        return http.Response('Not Found', 404);
      });

      final client = YouTubeClient(client: mockClient);
      final response = await client.fetchPlaylistData(
        const YouTubePlaylistRequest(playlistId: 'PLFallback123'),
      );

      expect(response.playlistId, 'PLFallback123');
      expect(response.title, 'Fallback Playlist Title');
      expect(response.author, 'Harold');
      expect(response.tracks.length, 1);
      expect(response.tracks[0].videoId, 'xmlVid12345');
      expect(response.tracks[0].title, 'Bon Jovi - Livin on a Prayer');
      expect(response.tracks[0].author, 'Bon Jovi');
    });

    test('fetchPlaylistData throws FormatException if playlistId is empty', () async {
      final client = YouTubeClient();
      expect(
        () => client.fetchPlaylistData(const YouTubePlaylistRequest(playlistId: '')),
        throwsA(isA<FormatException>()),
      );
    });

    test('fetchPlaylistData throws Exception when both web page and Atom feed fail', () async {
      final mockClient = MockClient((request) async => http.Response('Error', 500));
      final client = YouTubeClient(client: mockClient);

      expect(
        () => client.fetchPlaylistData(const YouTubePlaylistRequest(playlistId: 'PLNonexistent')),
        throwsA(isA<Exception>()),
      );
    });
  });
}
