import 'package:uuid/uuid.dart';
import '../../../../core/services/services.dart';
import '../../../songs/songs.dart';
import '../../data/repositories/playlist_repository.dart';
import '../models/playlist_sync_result.dart';
import 'playlist_sync_validator.dart';

/// Orchestrates the domain logic for synchronizing a local playlist
/// with its remote YouTube playlist counterpart.
class PlaylistSyncService {
  final PlaylistRepository _playlistRepository;
  final SongRepository? _songRepository;
  final YouTubeService? _youtubeService;
  final LyricsService? _lyricsService;
  final PlaylistSyncValidator _validator;

  PlaylistSyncService({
    required PlaylistRepository playlistRepository,
    SongRepository? songRepository,
    YouTubeService? youtubeService,
    LyricsService? lyricsService,
    PlaylistSyncValidator validator = const PlaylistSyncValidator(),
  })  : _playlistRepository = playlistRepository,
        _songRepository = songRepository,
        _youtubeService = youtubeService,
        _lyricsService = lyricsService,
        _validator = validator;

  /// Synchronizes playlist with its linked YouTube playlist URL.
  ///
  /// Adds songs from YouTube that are not yet in the playlist (creating them
  /// in [SongRepository] with lyrics via [LyricsService] if they don't exist in the library),
  /// and removes songs from the playlist that are no longer in the remote YouTube playlist.
  Future<PlaylistSyncResult> syncPlaylist(String playlistId) async {
    final playlist = await _playlistRepository.getPlaylistById(playlistId);
    final url = _validator.validatePlaylist(playlist);
    _validator.validateRequiredServices(
      youtubeService: _youtubeService,
      songRepository: _songRepository,
    );

    final yt = _youtubeService!;
    final songsRepo = _songRepository!;

    final metadata = await yt.fetchPlaylistMetadata(url);
    _validator.validateMetadata(metadata);

    final allSongs = List<Song>.from(await songsRepo.getAllSongs());
    final newSongIds = await _resolveSongIds(metadata.items, allSongs, yt, songsRepo);

    final updatedPlaylist = playlist!.copyWith(
      songIds: newSongIds,
      updatedAt: DateTime.now(),
    );

    await _playlistRepository.savePlaylist(updatedPlaylist);

    return _calculateDiff(playlist.songIds, newSongIds);
  }

  Future<List<String>> _resolveSongIds(
    List<YouTubePlaylistItem> items,
    List<Song> allSongs,
    YouTubeService yt,
    SongRepository songsRepo,
  ) async {
    final songIds = <String>[];

    for (final item in items) {
      final matchingSong = _findMatchingSong(item, allSongs, yt);
      if (matchingSong != null) {
        if (!songIds.contains(matchingSong.id)) {
          songIds.add(matchingSong.id);
        }
      } else {
        final newSong = await _createSongFromItem(item, songsRepo);
        allSongs.add(newSong);
        if (!songIds.contains(newSong.id)) {
          songIds.add(newSong.id);
        }
      }
    }

    return songIds;
  }

  Future<Song> _createSongFromItem(
    YouTubePlaylistItem item,
    SongRepository songsRepo,
  ) async {
    final lyrics = await _fetchLyricsSafe(item.title, item.artist);
    final now = DateTime.now();
    final newSong = Song(
      id: const Uuid().v4(),
      title: item.title,
      artist: item.artist,
      youtubeUrl: item.url,
      lyrics: lyrics,
      createdAt: now,
      updatedAt: now,
    );

    await songsRepo.saveSong(newSong);
    return newSong;
  }

  Future<String> _fetchLyricsSafe(String title, String artist) async {
    final service = _lyricsService;
    if (service == null) return '';
    try {
      final fetched = await service.fetchLyrics(
        title: title,
        artist: artist,
      );
      return fetched ?? '';
    } catch (_) {
      // Failure to fetch lyrics should not abort sync
      return '';
    }
  }

  PlaylistSyncResult _calculateDiff(List<String> oldSongIds, List<String> newSongIds) {
    final addedCount = newSongIds.where((id) => !oldSongIds.contains(id)).length;
    final removedCount = oldSongIds.where((id) => !newSongIds.contains(id)).length;

    return PlaylistSyncResult(
      addedCount: addedCount,
      removedCount: removedCount,
      totalCount: newSongIds.length,
    );
  }

  Song? _findMatchingSong(
    YouTubePlaylistItem item,
    List<Song> existingSongs,
    YouTubeService ytService,
  ) {
    final itemVideoId =
        ytService.extractVideoId(item.url) ?? (item.videoId.isNotEmpty ? item.videoId : null);
    final itemTitle = item.title.trim().toLowerCase();
    final itemArtist = item.artist.trim().toLowerCase();

    for (final song in existingSongs) {
      if (song.youtubeUrl != null && song.youtubeUrl!.trim().isNotEmpty) {
        final songUrl = song.youtubeUrl!.trim();
        if (item.url.trim().isNotEmpty && songUrl == item.url.trim()) {
          return song;
        }
        final songVideoId = ytService.extractVideoId(songUrl);
        if (songVideoId != null && itemVideoId != null && songVideoId == itemVideoId) {
          return song;
        }
      }

      if (song.title.trim().toLowerCase() == itemTitle &&
          song.artist.trim().toLowerCase() == itemArtist) {
        return song;
      }
    }
    return null;
  }
}
