import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import 'models/youtube_oembed_request.dart';
import 'models/youtube_oembed_response.dart';
import 'models/youtube_playlist_request.dart';
import 'models/youtube_playlist_response.dart';
import 'models/youtube_playlist_track_item.dart';

/// HTTP client responsible for making direct requests to YouTube open endpoints
class YouTubeClient {
  final http.Client _client;

  YouTubeClient({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches video metadata from YouTube's oEmbed open endpoint using [YouTubeOembedRequest].
  Future<YouTubeOembedResponse> fetchOEmbedData(
    YouTubeOembedRequest request,
  ) async {
    final oembedUri = Uri.parse(ApiConfig.youtubeOembedBaseUrl).replace(
      queryParameters: request.toQueryParameters(),
    );

    final response = await _client.get(oembedUri);
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch YouTube oEmbed data: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return YouTubeOembedResponse.fromJson(data);
  }

  /// Fetches playlist metadata and tracks for a YouTube playlist using [YouTubePlaylistRequest].
  /// Employs a resilient approach: tries parsing the public playlist page (`ytInitialData`)
  /// and falls back to YouTube's Atom XML feed (`feeds/videos.xml?playlist_id=...`).
  Future<YouTubePlaylistResponse> fetchPlaylistData(
    YouTubePlaylistRequest request,
  ) async {
    final playlistId = request.playlistId.trim();
    if (playlistId.isEmpty) {
      throw const FormatException('Playlist ID cannot be empty');
    }

    // 1. Try parsing ytInitialData from the web playlist page
    try {
      final webUri = Uri.parse(ApiConfig.youtubePlaylistBaseUrl).replace(
        queryParameters: {'list': playlistId},
      );
      final webResponse = await _client.get(
        webUri,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept-Language': 'en-US,en;q=0.9',
        },
      );

      if (webResponse.statusCode == 200) {
        final parsed = _parseYtInitialData(webResponse.body, playlistId);
        if (parsed != null && parsed.tracks.isNotEmpty) {
          return parsed;
        }
      }
    } catch (_) {
      // Fall through to Atom feed fallback
    }

    // 2. Fallback: Parse YouTube's official Atom XML feed
    try {
      final feedUri = Uri.parse(ApiConfig.youtubeFeedsVideosUrl).replace(
        queryParameters: {'playlist_id': playlistId},
      );
      final feedResponse = await _client.get(feedUri);

      if (feedResponse.statusCode == 200) {
        final parsed = _parseAtomFeed(feedResponse.body, playlistId);
        if (parsed.tracks.isNotEmpty) {
          return parsed;
        }
      }
    } catch (_) {
      // Fall through to error
    }

    throw Exception(
      'Failed to fetch tracks for YouTube playlist ID: $playlistId',
    );
  }

  YouTubePlaylistResponse? _parseYtInitialData(
    String html,
    String playlistId,
  ) {
    final regex = RegExp(
      r'var ytInitialData\s*=\s*({.*?});</script>|ytInitialData\s*=\s*({.*?});',
      dotAll: true,
    );
    final match = regex.firstMatch(html);
    if (match == null) return null;

    final jsonStr = match.group(1) ?? match.group(2);
    if (jsonStr == null) return null;

    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      // Extract playlist title
      String title = 'YouTube Playlist';
      String? author;

      final header = data['header'] as Map<String, dynamic>?;
      if (header != null) {
        final playlistHeader =
            header['playlistHeaderRenderer'] as Map<String, dynamic>?;
        if (playlistHeader != null) {
          final titleObj = playlistHeader['title'];
          if (titleObj is Map<String, dynamic>) {
            title = titleObj['simpleText'] as String? ??
                (titleObj['runs'] as List?)?.firstOrNull?['text'] as String? ??
                title;
          }
          final ownerObj = playlistHeader['ownerText'];
          if (ownerObj is Map<String, dynamic>) {
            author = (ownerObj['runs'] as List?)?.firstOrNull?['text'] as String?;
          }
        }
      }

      final tracks = <YouTubePlaylistTrackItem>[];
      _collectPlaylistVideoRenderers(data, tracks);

      return YouTubePlaylistResponse(
        playlistId: playlistId,
        title: title,
        author: author,
        tracks: tracks,
      );
    } catch (_) {
      return null;
    }
  }

  void _collectPlaylistVideoRenderers(
    dynamic node,
    List<YouTubePlaylistTrackItem> tracks,
  ) {
    if (node is Map<String, dynamic>) {
      if (node.containsKey('playlistVideoRenderer')) {
        final pvr = node['playlistVideoRenderer'] as Map<String, dynamic>;
        final videoId = pvr['videoId'] as String?;
        if (videoId != null && videoId.isNotEmpty) {
          String videoTitle = 'Unknown Title';
          final titleObj = pvr['title'];
          if (titleObj is Map<String, dynamic>) {
            videoTitle = (titleObj['runs'] as List?)?.firstOrNull?['text']
                    as String? ??
                titleObj['simpleText'] as String? ??
                videoTitle;
          }

          String videoAuthor = 'Unknown Artist';
          final bylineObj = pvr['shortBylineText'];
          if (bylineObj is Map<String, dynamic>) {
            videoAuthor = (bylineObj['runs'] as List?)?.firstOrNull?['text']
                    as String? ??
                videoAuthor;
          }

          String? thumbnail;
          final thumbObj = pvr['thumbnail'];
          if (thumbObj is Map<String, dynamic>) {
            final thumbs = thumbObj['thumbnails'] as List?;
            if (thumbs != null && thumbs.isNotEmpty) {
              thumbnail = (thumbs.last as Map<String, dynamic>?)?['url'] as String?;
            }
          }

          tracks.add(
            YouTubePlaylistTrackItem(
              videoId: videoId,
              title: _unescapeHtml(videoTitle),
              author: _unescapeHtml(videoAuthor),
              thumbnailUrl: thumbnail,
              videoUrl: '${ApiConfig.youtubeWatchBaseUrl}?v=$videoId',
            ),
          );
        }
      }
      for (final val in node.values) {
        _collectPlaylistVideoRenderers(val, tracks);
      }
    } else if (node is List) {
      for (final item in node) {
        _collectPlaylistVideoRenderers(item, tracks);
      }
    }
  }

  YouTubePlaylistResponse _parseAtomFeed(String xml, String playlistId) {
    final titleMatch = RegExp(r'<title>(.*?)</title>').firstMatch(xml);
    final playlistTitle = _unescapeHtml(titleMatch?.group(1) ?? 'YouTube Playlist');

    final authorMatch =
        RegExp(r'<author>\s*<name>(.*?)</name>', dotAll: true).firstMatch(xml);
    final playlistAuthor =
        authorMatch != null ? _unescapeHtml(authorMatch.group(1)!) : null;

    final entryRegex = RegExp(r'<entry>(.*?)</entry>', dotAll: true);
    final entries = entryRegex.allMatches(xml);

    final tracks = <YouTubePlaylistTrackItem>[];

    for (final entry in entries) {
      final entryContent = entry.group(1) ?? '';
      final videoIdMatch =
          RegExp(r'<yt:videoId>(.*?)</yt:videoId>').firstMatch(entryContent);
      final videoId = videoIdMatch?.group(1)?.trim();
      if (videoId == null || videoId.isEmpty) continue;

      final titleMatch =
          RegExp(r'<media:title>(.*?)</media:title>').firstMatch(entryContent) ??
              RegExp(r'<title>(.*?)</title>').firstMatch(entryContent);
      final title = _unescapeHtml(titleMatch?.group(1)?.trim() ?? 'Unknown Title');

      final artistMatch = RegExp(r'<author>\s*<name>(.*?)</name>', dotAll: true)
          .firstMatch(entryContent);
      final artist = _unescapeHtml(artistMatch?.group(1)?.trim() ?? 'Unknown Artist');

      final thumbMatch =
          RegExp(r'<media:thumbnail[^>]+url="([^"]+)"').firstMatch(entryContent);
      final thumb = thumbMatch?.group(1);

      tracks.add(
        YouTubePlaylistTrackItem(
          videoId: videoId,
          title: title,
          author: artist,
          thumbnailUrl: thumb,
          videoUrl: '${ApiConfig.youtubeWatchBaseUrl}?v=$videoId',
        ),
      );
    }

    return YouTubePlaylistResponse(
      playlistId: playlistId,
      title: playlistTitle,
      author: playlistAuthor,
      tracks: tracks,
    );
  }

  static String _unescapeHtml(String text) {
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }
}
