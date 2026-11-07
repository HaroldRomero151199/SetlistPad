import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:setlist_pad/core/clients/clients.dart';

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
<feed xmlns:yt="http://www.youtube.com/xml/schemas/2015" xmlns:media="http://search.yahoo.com/mrss/" xmlns="http://www.w3.org/2005/Atom">
 <link rel="self" href="http://www.youtube.com/feeds/videos.xml?playlist_id=PLFallback123"/>
 <id>yt:playlist:PLFallback123</id>
 <title>Acoustic Live Concerts</title>
 <author>
  <name>John Mayer</name>
 </author>
 <entry>
  <id>yt:video:vidAtom001</id>
  <yt:videoId>vidAtom001</yt:videoId>
  <title>John Mayer - Gravity (Live in LA)</title>
  <link rel="alternate" href="https://www.youtube.com/watch?v=vidAtom001"/>
  <author>
   <name>John Mayer</name>
  </author>
  <media:thumbnail url="https://i.ytimg.com/vi/vidAtom001/hqdefault.jpg"/>
 </entry>
 <entry>
  <id>yt:video:vidAtom002</id>
  <yt:videoId>vidAtom002</yt:videoId>
  <title>Slow Dancing in a Burning Room</title>
  <link rel="alternate" href="https://www.youtube.com/watch?v=vidAtom002"/>
  <author>
   <name>John Mayer</name>
  </author>
 </entry>
</feed>
''';

      final mockClient = MockClient((request) async {
        if (request.url.path == '/playlist') {
          return http.Response('<html>No ytInitialData here</html>', 200);
        }
        if (request.url.path == '/feeds/videos.xml') {
          return http.Response(atomXml, 200);
        }
        return http.Response('Not Found', 404);
      });

      final client = YouTubeClient(client: mockClient);
      final response = await client.fetchPlaylistData(
        const YouTubePlaylistRequest(playlistId: 'PLFallback123'),
      );

      expect(response.playlistId, 'PLFallback123');
      expect(response.title, 'Acoustic Live Concerts');
      expect(response.author, 'John Mayer');
      expect(response.tracks.length, 2);
      expect(response.tracks[0].videoId, 'vidAtom001');
      expect(response.tracks[0].title, 'John Mayer - Gravity (Live in LA)');
      expect(response.tracks[0].author, 'John Mayer');
      expect(response.tracks[0].thumbnailUrl, 'https://i.ytimg.com/vi/vidAtom001/hqdefault.jpg');
      expect(response.tracks[0].videoUrl, 'https://www.youtube.com/watch?v=vidAtom001');
      expect(response.tracks[1].videoId, 'vidAtom002');
      expect(response.tracks[1].title, 'Slow Dancing in a Burning Room');
      expect(response.tracks[1].author, 'John Mayer');
    });

    test('fetchPlaylistData throws FormatException if playlistId is empty', () async {
      final client = YouTubeClient();
      expect(
        () => client.fetchPlaylistData(const YouTubePlaylistRequest(playlistId: '   ')),
        throwsA(isA<FormatException>()),
      );
    });

    test('fetchPlaylistData throws Exception when both web page and Atom feed fail', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final client = YouTubeClient(client: mockClient);
      expect(
        () => client.fetchPlaylistData(const YouTubePlaylistRequest(playlistId: 'PLBroken')),
        throwsA(isA<Exception>()),
      );
    });

    test('fetchPlaylistData follows continuation pages to fetch all tracks', () async {
      final initialPageHtml = '''
      <!DOCTYPE html>
      <html>
      <body>
        <script>
          var ytInitialData = {
            "header": {
              "playlistHeaderRenderer": {
                "title": {"simpleText": "Paginated Playlist"}
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
                                      "videoId": "vid_page_1",
                                      "title": {"simpleText": "Track 1"}
                                    }
                                  },
                                  {
                                    "continuationItemRenderer": {
                                      "continuationEndpoint": {
                                        "continuationCommand": {
                                          "token": "token_page_2"
                                        }
                                      }
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
          window.ytcfg = {"INNERTUBE_API_KEY": "FakeKey123"};
        </script>
      </body>
      </html>
      ''';

      final mockClient = MockClient((request) async {
        if (request.url.path == '/playlist') {
          return http.Response(initialPageHtml, 200);
        }
        if (request.url.path == '/youtubei/v1/browse') {
          expect(request.method, 'POST');
          expect(request.url.queryParameters['key'], 'FakeKey123');
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['continuation'], 'token_page_2');

          return http.Response(
            jsonEncode({
              'onResponseReceivedActions': [
                {
                  'appendContinuationItemsAction': {
                    'continuationItems': [
                      {
                        'playlistVideoRenderer': {
                          'videoId': 'vid_page_2',
                          'title': {'simpleText': 'Track 2'},
                        },
                      },
                    ],
                  },
                },
              ],
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final client = YouTubeClient(client: mockClient);
      final response = await client.fetchPlaylistData(
        const YouTubePlaylistRequest(playlistId: 'PLPaginated'),
      );

      expect(response.title, 'Paginated Playlist');
      expect(response.tracks.length, 2);
      expect(response.tracks[0].videoId, 'vid_page_1');
      expect(response.tracks[0].title, 'Track 1');
      expect(response.tracks[1].videoId, 'vid_page_2');
      expect(response.tracks[1].title, 'Track 2');
    });

    test('fetchPlaylistData falls back to Atom XML feed when web page request fails', () async {
      const atomXml = '''<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns:yt="http://www.youtube.com/xml/schemas/2015" xmlns:media="http://search.yahoo.com/mrss/" xmlns="http://www.w3.org/2005/Atom">
 <title>Fallback Playlist</title>
 <author><name>FallbackArtist</name></author>
 <entry>
  <yt:videoId>fallback_vid_1</yt:videoId>
  <title>Fallback Track 1</title>
  <author><name>FallbackArtist</name></author>
 </entry>
</feed>''';

      final mockClient = MockClient((request) async {
        if (request.url.path == '/feeds/videos.xml') {
          return http.Response(atomXml, 200);
        }
        return http.Response('Internal Server Error', 500);
      });

      final client = YouTubeClient(client: mockClient);
      final response = await client.fetchPlaylistData(
        const YouTubePlaylistRequest(playlistId: 'PLFallback123'),
      );

      expect(response.title, 'Fallback Playlist');
      expect(response.author, 'FallbackArtist');
      expect(response.tracks.length, 1);
      expect(response.tracks.first.videoId, 'fallback_vid_1');
      expect(response.tracks.first.title, 'Fallback Track 1');
    });
  });
}
