import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/services/services.dart';
import '../../../playlists/playlists.dart';
import '../../songs.dart';

final songRepositoryProvider = Provider<SongRepository>((ref) {
  final box = ref.watch(songBoxProvider);
  return HiveSongRepository(songBox: box);
});

class SongsNotifier extends Notifier<AsyncValue<List<Song>>> {
  final SongRepository? _repository;
  final PlaylistRepository? _playlistRepository;
  final YouTubeService? _youtubeService;
  final LyricsService? _lyricsService;

  SongsNotifier({
    SongRepository? repository,
    PlaylistRepository? playlistRepository,
    YouTubeService? youtubeService,
    LyricsService? lyricsService,
  })  : _repository = repository,
        _playlistRepository = playlistRepository,
        _youtubeService = youtubeService,
        _lyricsService = lyricsService;

  SongRepository get repository =>
      _repository ?? ref.read(songRepositoryProvider);

  PlaylistRepository? get playlistRepository {
    if (_playlistRepository != null) return _playlistRepository;
    try {
      return ref.read(playlistRepositoryProvider);
    } catch (_) {
      return null;
    }
  }

  YouTubeService get youtubeService =>
      _youtubeService ?? ref.read(youtubeServiceProvider);

  LyricsService get lyricsService =>
      _lyricsService ?? ref.read(lyricsServiceProvider);

  @override
  AsyncValue<List<Song>> get state => super.state;

  @override
  AsyncValue<List<Song>> build() {
    loadSongs();
    return const AsyncValue.loading();
  }

  Future<void> loadSongs() async {
    try {
      final songs = await repository.getAllSongs();
      state = AsyncValue.data(songs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Song> importSongFromYoutubeUrl(String youtubeUrl) async {
    final metadata = await youtubeService.fetchVideoMetadata(youtubeUrl);
    final lyrics = await lyricsService.fetchLyrics(
          title: metadata.title,
          artist: metadata.artist,
        ) ??
        '';

    final now = DateTime.now();
    final newSong = Song(
      id: const Uuid().v4(),
      title: metadata.title,
      artist: metadata.artist,
      youtubeUrl: metadata.url,
      lyrics: lyrics,
      createdAt: now,
      updatedAt: now,
    );

    await repository.saveSong(newSong);
    await loadSongs();
    return newSong;
  }

  Future<List<Song>> importSongsBatch(
    List<YouTubePlaylistItem> items, {
    String? targetPlaylistId,
    void Function(int current, int total)? onProgress,
  }) async {
    final importedSongs = <Song>[];
    final total = items.length;

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      onProgress?.call(i + 1, total);

      String lyrics = '';
      try {
        lyrics = await lyricsService.fetchLyrics(
              title: item.title,
              artist: item.artist,
            ) ??
            '';
      } catch (_) {
        // Fallback: continue batch import even if lyrics service is unavailable
      }

      final now = DateTime.now();
      final song = Song(
        id: const Uuid().v4(),
        title: item.title,
        artist: item.artist,
        youtubeUrl: item.url,
        lyrics: lyrics,
        createdAt: now,
        updatedAt: now,
      );

      await repository.saveSong(song);
      importedSongs.add(song);

      if (targetPlaylistId != null) {
        final plRepo = playlistRepository;
        if (plRepo != null) {
          await plRepo.addSongToPlaylist(targetPlaylistId, song.id);
        }
      }
    }

    await loadSongs();

    if (targetPlaylistId != null) {
      try {
        await ref.read(playlistsNotifierProvider.notifier).loadPlaylists();
      } catch (_) {
        // Safe fallback in isolated test setups
      }
    }

    return importedSongs;
  }

  Future<bool> fetchAndSaveLyrics(String songId) async {
    final song = await repository.getSongById(songId);
    if (song == null) return false;

    final lyrics = await lyricsService.fetchLyrics(
      title: song.title,
      artist: song.artist,
    );

    if (lyrics != null && lyrics.trim().isNotEmpty) {
      await updateLyrics(songId, lyrics.trim());
      return true;
    }

    return false;
  }

  Future<void> addSong({
    required String title,
    required String artist,
    String? youtubeUrl,
    required String lyrics,
  }) async {
    final now = DateTime.now();
    final song = Song(
      id: const Uuid().v4(),
      title: title,
      artist: artist,
      youtubeUrl: youtubeUrl,
      lyrics: lyrics,
      createdAt: now,
      updatedAt: now,
    );
    await repository.saveSong(song);
    await loadSongs();
  }

  Future<void> updateLyrics(String songId, String newLyrics) async {
    final song = await repository.getSongById(songId);
    if (song != null) {
      final updated = song.copyWith(
        lyrics: newLyrics,
        updatedAt: DateTime.now(),
      );
      await repository.saveSong(updated);
      await loadSongs();
    }
  }

  Future<void> deleteSong(String songId) async {
    await repository.deleteSong(songId);
    final plRepo = playlistRepository;
    if (plRepo != null) {
      await plRepo.removeSongFromAllPlaylists(songId);
      try {
        await ref.read(playlistsNotifierProvider.notifier).loadPlaylists();
      } catch (_) {
        // Safe fallback in isolated test setups
      }
    }
    await loadSongs();
  }
}

final songsNotifierProvider =
    NotifierProvider<SongsNotifier, AsyncValue<List<Song>>>(
  SongsNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  set query(String val) => state = val;
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

final filteredSongsProvider = Provider<AsyncValue<List<Song>>>((ref) {
  final songsAsync = ref.watch(songsNotifierProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();

  return songsAsync.whenData((songs) {
    if (query.isEmpty) return songs;
    return songs.where((s) {
      return s.title.toLowerCase().contains(query) ||
          s.artist.toLowerCase().contains(query);
    }).toList();
  });
});
