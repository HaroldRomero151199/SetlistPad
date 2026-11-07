import 'package:flutter_test/flutter_test.dart';
import 'package:setlist_pad/core/services/services.dart';
import 'package:setlist_pad/features/playlists/playlists.dart';
import 'package:setlist_pad/features/songs/songs.dart';

class _FakeSongRepository implements SongRepository {
  @override
  Future<void> deleteSong(String id) async {}

  @override
  Future<List<Song>> getAllSongs() async => [];

  @override
  Future<Song?> getSongById(String id) async => null;

  @override
  Future<void> saveSong(Song song) async {}

  @override
  Future<List<Song>> searchSongs(String query) async => [];
}

class _FakeYouTubeService extends YouTubeService {
  @override
  Future<YouTubePlaylistMetadata> fetchPlaylistMetadata(String playlistUrl) async {
    return YouTubePlaylistMetadata(id: 'pl-1', title: 'Test', items: const []);
  }
}

void main() {
  group('PlaylistSyncValidator Tests', () {
    const validator = PlaylistSyncValidator();

    group('validatePlaylist', () {
      test('throws Exception when playlist is null', () {
        expect(
          () => validator.validatePlaylist(null),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Playlist not found'),
            ),
          ),
        );
      });

      test('throws FormatException when youtubePlaylistUrl is null', () {
        final playlist = Playlist(
          id: 'p-1',
          name: 'Setlist',
          youtubePlaylistUrl: null,
          songIds: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(
          () => validator.validatePlaylist(playlist),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('Playlist has no YouTube playlist URL'),
            ),
          ),
        );
      });

      test('throws FormatException when youtubePlaylistUrl is empty or blank', () {
        final playlist = Playlist(
          id: 'p-1',
          name: 'Setlist',
          youtubePlaylistUrl: '   ',
          songIds: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(
          () => validator.validatePlaylist(playlist),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('Playlist has no YouTube playlist URL'),
            ),
          ),
        );
      });

      test('returns trimmed URL when valid', () {
        final playlist = Playlist(
          id: 'p-1',
          name: 'Setlist',
          youtubePlaylistUrl: '  https://youtube.com/playlist?list=PL123  ',
          songIds: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final result = validator.validatePlaylist(playlist);
        expect(result, 'https://youtube.com/playlist?list=PL123');
      });
    });

    group('validateRequiredServices', () {
      test('throws StateError if youtubeService is null', () {
        expect(
          () => validator.validateRequiredServices(
            youtubeService: null,
            songRepository: _FakeSongRepository(),
          ),
          throwsA(isA<StateError>()),
        );
      });

      test('throws StateError if songRepository is null', () {
        expect(
          () => validator.validateRequiredServices(
            youtubeService: _FakeYouTubeService(),
            songRepository: null,
          ),
          throwsA(isA<StateError>()),
        );
      });

      test('does not throw when both services are present', () {
        expect(
          () => validator.validateRequiredServices(
            youtubeService: _FakeYouTubeService(),
            songRepository: _FakeSongRepository(),
          ),
          returnsNormally,
        );
      });
    });

    group('validateMetadata', () {
      test('throws Exception when metadata items list is empty', () {
        final metadata = YouTubePlaylistMetadata(
          id: 'pl-1',
          title: 'Empty Playlist',
          items: const [],
        );

        expect(
          () => validator.validateMetadata(metadata),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Playlist is empty or private'),
            ),
          ),
        );
      });

      test('throws Exception when metadata snapshot is marked incomplete', () {
        final metadata = YouTubePlaylistMetadata(
          id: 'pl-1',
          title: 'Truncated Playlist',
          items: [
            YouTubePlaylistItem(
              videoId: 'v1',
              title: 'Song 1',
              artist: 'Artist 1',
              rawTitle: 'Artist 1 - Song 1',
              url: 'https://youtube.com/watch?v=v1',
            ),
          ],
          isComplete: false,
        );

        expect(
          () => validator.validateMetadata(metadata),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Remote playlist snapshot is incomplete'),
            ),
          ),
        );
      });

      test('does not throw when metadata contains items and is complete', () {
        final metadata = YouTubePlaylistMetadata(
          id: 'pl-1',
          title: 'Full Playlist',
          items: [
            YouTubePlaylistItem(
              videoId: 'v1',
              title: 'Song 1',
              artist: 'Artist 1',
              rawTitle: 'Artist 1 - Song 1',
              url: 'https://youtube.com/watch?v=v1',
            ),
          ],
          isComplete: true,
        );

        expect(() => validator.validateMetadata(metadata), returnsNormally);
      });
    });
  });
}
