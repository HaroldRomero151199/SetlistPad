import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/services/services.dart';
import '../../../songs/songs.dart';
import '../../playlists.dart';

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  final box = ref.watch(playlistBoxProvider);
  return HivePlaylistRepository(playlistBox: box);
});

final playlistSyncValidatorProvider = Provider<PlaylistSyncValidator>((ref) {
  return const PlaylistSyncValidator();
});

final playlistSyncServiceProvider = Provider<PlaylistSyncService>((ref) {
  return PlaylistSyncService(
    playlistRepository: ref.watch(playlistRepositoryProvider),
    songRepository: ref.watch(songRepositoryProvider),
    youtubeService: ref.watch(youtubeServiceProvider),
    lyricsService: ref.watch(lyricsServiceProvider),
    validator: ref.watch(playlistSyncValidatorProvider),
  );
});

class PlaylistsNotifier extends Notifier<AsyncValue<List<Playlist>>> {
  final PlaylistRepository? _repository;
  final SongRepository? _songRepository;
  final YouTubeService? _youtubeService;
  final LyricsService? _lyricsService;
  final PlaylistSyncService? _syncService;

  PlaylistsNotifier({
    PlaylistRepository? repository,
    SongRepository? songRepository,
    YouTubeService? youtubeService,
    LyricsService? lyricsService,
    PlaylistSyncService? syncService,
  })  : _repository = repository,
        _songRepository = songRepository,
        _youtubeService = youtubeService,
        _lyricsService = lyricsService,
        _syncService = syncService;

  PlaylistRepository get repository =>
      _repository ?? ref.read(playlistRepositoryProvider);

  SongRepository? get songRepository {
    if (_songRepository != null) return _songRepository;
    try {
      return ref.read(songRepositoryProvider);
    } catch (_) {
      return null;
    }
  }

  YouTubeService? get youtubeService {
    if (_youtubeService != null) return _youtubeService;
    try {
      return ref.read(youtubeServiceProvider);
    } catch (_) {
      return null;
    }
  }

  LyricsService? get lyricsService {
    if (_lyricsService != null) return _lyricsService;
    try {
      return ref.read(lyricsServiceProvider);
    } catch (_) {
      return null;
    }
  }

  PlaylistSyncService get syncService {
    if (_syncService != null) return _syncService;
    return PlaylistSyncService(
      playlistRepository: repository,
      songRepository: songRepository,
      youtubeService: youtubeService,
      lyricsService: lyricsService,
    );
  }

  @override
  AsyncValue<List<Playlist>> get state => super.state;

  @override
  AsyncValue<List<Playlist>> build() {
    loadPlaylists();
    return const AsyncValue.loading();
  }

  Future<void> loadPlaylists() async {
    try {
      final playlists = await repository.getAllPlaylists();
      state = AsyncValue.data(playlists);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Playlist> createPlaylist({
    required String name,
    String description = '',
    String? youtubePlaylistUrl,
    List<String> songIds = const [],
  }) async {
    final now = DateTime.now();
    final newPlaylist = Playlist(
      id: const Uuid().v4(),
      name: name,
      description: description,
      youtubePlaylistUrl: youtubePlaylistUrl,
      songIds: songIds,
      createdAt: now,
      updatedAt: now,
    );

    await repository.savePlaylist(newPlaylist);
    await loadPlaylists();
    return newPlaylist;
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    await repository.addSongToPlaylist(playlistId, songId);
    await loadPlaylists();
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    await repository.removeSongFromPlaylist(playlistId, songId);
    await loadPlaylists();
  }

  Future<void> removeSongFromAllPlaylists(String songId) async {
    await repository.removeSongFromAllPlaylists(songId);
    await loadPlaylists();
  }

  Future<void> deletePlaylist(String playlistId) async {
    await repository.deletePlaylist(playlistId);
    await loadPlaylists();
  }

  /// Synchronizes playlist with its linked YouTube playlist URL via [PlaylistSyncService].
  Future<PlaylistSyncResult> syncPlaylist(String playlistId) async {
    final result = await syncService.syncPlaylist(playlistId);
    await loadPlaylists();
    _reloadSongs();
    return result;
  }

  void _reloadSongs() {
    try {
      ref.read(songsNotifierProvider.notifier).loadSongs();
    } catch (_) {
      // Safe fallback in isolated test setups
    }
  }
}

final playlistsNotifierProvider =
    NotifierProvider<PlaylistsNotifier, AsyncValue<List<Playlist>>>(
  PlaylistsNotifier.new,
);
