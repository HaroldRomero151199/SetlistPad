import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/services/services.dart';
import '../../songs.dart';

final songRepositoryProvider = Provider<SongRepository>((ref) {
  final box = ref.watch(songBoxProvider);
  return HiveSongRepository(songBox: box);
});

class SongsNotifier extends Notifier<AsyncValue<List<Song>>> {
  final SongRepository? _repository;
  final YouTubeService? _youtubeService;
  final LyricsService? _lyricsService;

  SongsNotifier({
    SongRepository? repository,
    YouTubeService? youtubeService,
    LyricsService? lyricsService,
  })  : _repository = repository,
        _youtubeService = youtubeService,
        _lyricsService = lyricsService;

  SongRepository get repository =>
      _repository ?? ref.read(songRepositoryProvider);

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
