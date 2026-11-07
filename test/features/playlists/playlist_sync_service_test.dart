import 'package:flutter_test/flutter_test.dart';
import 'package:setlist_pad/core/services/services.dart';
import 'package:setlist_pad/features/playlists/playlists.dart';
import 'package:setlist_pad/features/songs/songs.dart';

class _FakeSongRepository implements SongRepository {
  final List<Song> songs = [];

  @override
  Future<void> deleteSong(String id) async {
    songs.removeWhere((s) => s.id == id);
  }

  @override
  Future<List<Song>> getAllSongs() async => List.unmodifiable(songs);

  @override
  Future<Song?> getSongById(String id) async {
    try {
      return songs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveSong(Song song) async {
    final index = songs.indexWhere((s) => s.id == song.id);
    if (index >= 0) {
      songs[index] = song;
    } else {
      songs.add(song);
    }
  }

  @override
  Future<List<Song>> searchSongs(String query) async => [];
}

class _FakePlaylistRepository implements PlaylistRepository {
  final Map<String, Playlist> playlists = {};

  @override
  Future<List<Playlist>> getAllPlaylists() async => playlists.values.toList();

  @override
  Future<Playlist?> getPlaylistById(String id) async => playlists[id];

  @override
  Future<void> savePlaylist(Playlist playlist) async {
    playlists[playlist.id] = playlist;
  }

  @override
  Future<void> deletePlaylist(String id) async {
    playlists.remove(id);
  }

  @override
  Future<void> addSongToPlaylist(String playlistId, String songId) async {}

  @override
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {}

  @override
  Future<void> removeSongFromAllPlaylists(String songId) async {}
}

class _FakeYouTubeService extends YouTubeService {
  YouTubePlaylistMetadata? metadataToReturn;

  @override
  Future<YouTubePlaylistMetadata> fetchPlaylistMetadata(String playlistUrl) async {
    if (metadataToReturn != null) return metadataToReturn!;
    return YouTubePlaylistMetadata(id: 'pl-1', title: 'Remote', items: const []);
  }

  @override
  String? extractVideoId(String url) {
    final uri = Uri.tryParse(url);
    return uri?.queryParameters['v'];
  }
}

class _FakeLyricsService extends LyricsService {
  @override
  Future<String?> fetchLyrics({required String title, required String artist}) async {
    return 'Lyrics for $title';
  }
}

void main() {
  group('PlaylistSyncService Tests', () {
    late _FakePlaylistRepository playlistRepo;
    late _FakeSongRepository songRepo;
    late _FakeYouTubeService ytService;
    late _FakeLyricsService lyricsService;
    late PlaylistSyncService service;

    setUp(() {
      playlistRepo = _FakePlaylistRepository();
      songRepo = _FakeSongRepository();
      ytService = _FakeYouTubeService();
      lyricsService = _FakeLyricsService();
      service = PlaylistSyncService(
        playlistRepository: playlistRepo,
        songRepository: songRepo,
        youtubeService: ytService,
        lyricsService: lyricsService,
      );
    });

    test('synchronizes tracks and creates new songs with lyrics', () async {
      final now = DateTime.now();
      final playlist = Playlist(
        id: 'pl-test',
        name: 'My Live Set',
        youtubePlaylistUrl: 'https://youtube.com/playlist?list=PLXYZ',
        songIds: const ['old-song-id'],
        createdAt: now,
        updatedAt: now,
      );
      await playlistRepo.savePlaylist(playlist);

      ytService.metadataToReturn = YouTubePlaylistMetadata(
        id: 'PLXYZ',
        title: 'Remote Set',
        items: [
          YouTubePlaylistItem(
            videoId: 'vid1',
            title: 'New Track',
            artist: 'Top Artist',
            rawTitle: 'Top Artist - New Track',
            url: 'https://youtube.com/watch?v=vid1',
          ),
        ],
      );

      final result = await service.syncPlaylist('pl-test');

      expect(result.addedCount, 1);
      expect(result.removedCount, 1);
      expect(result.totalCount, 1);

      final updated = await playlistRepo.getPlaylistById('pl-test');
      expect(updated, isNotNull);
      expect(updated!.songIds.contains('old-song-id'), isFalse);

      final createdSong = (await songRepo.getAllSongs()).first;
      expect(createdSong.title, 'New Track');
      expect(createdSong.artist, 'Top Artist');
      expect(createdSong.lyrics, 'Lyrics for New Track');
      expect(updated.songIds, [createdSong.id]);
    });

    test('matches existing song by title and artist without creating duplicates', () async {
      final now = DateTime.now();
      final existingSong = Song(
        id: 'existing-id',
        title: 'Californication',
        artist: 'RHCP',
        lyrics: 'Psychic spies...',
        createdAt: now,
        updatedAt: now,
      );
      await songRepo.saveSong(existingSong);

      final playlist = Playlist(
        id: 'pl-rhcp',
        name: 'RHCP Set',
        youtubePlaylistUrl: 'https://youtube.com/playlist?list=PLRHCP',
        songIds: const [],
        createdAt: now,
        updatedAt: now,
      );
      await playlistRepo.savePlaylist(playlist);

      ytService.metadataToReturn = YouTubePlaylistMetadata(
        id: 'PLRHCP',
        title: 'RHCP',
        items: [
          YouTubePlaylistItem(
            videoId: 'rhcp-vid',
            title: 'californication',
            artist: 'rhcp',
            rawTitle: 'RHCP - Californication',
            url: 'https://youtube.com/watch?v=rhcp-vid',
          ),
        ],
      );

      final result = await service.syncPlaylist('pl-rhcp');
      expect(result.addedCount, 1);
      expect(result.totalCount, 1);

      final allSongs = await songRepo.getAllSongs();
      expect(allSongs.length, 1);
      expect(allSongs.first.id, 'existing-id');

      final updated = await playlistRepo.getPlaylistById('pl-rhcp');
      expect(updated!.songIds, ['existing-id']);
    });
  });
}
