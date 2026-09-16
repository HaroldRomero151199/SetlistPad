import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:setlist_pad/core/providers/providers.dart';
import 'package:setlist_pad/core/services/services.dart';
import 'package:setlist_pad/features/songs/songs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Box<Song> songBox;
  late SongRepository repository;
  late YouTubeService youtubeService;
  late LyricsService lyricsService;
  late ProviderContainer container;
  late SongsNotifier notifier;

  setUp(() async {
    Hive.init('./test_hive_songs_notifier');
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SongAdapter());
    }
    songBox = await Hive.openBox<Song>('test_songs_box');
    await songBox.clear();

    repository = HiveSongRepository(songBox: songBox);
    youtubeService = YouTubeService();
    lyricsService = LyricsService();

    container = ProviderContainer(
      overrides: [
        songRepositoryProvider.overrideWithValue(repository),
        youtubeServiceProvider.overrideWithValue(youtubeService),
        lyricsServiceProvider.overrideWithValue(lyricsService),
      ],
    );

    notifier = container.read(songsNotifierProvider.notifier);
  });

  tearDown(() async {
    container.dispose();
    await songBox.close();
    await Hive.deleteBoxFromDisk('test_songs_box');
  });

  group('SongsNotifier Tests', () {
    test('addSong should save a new song to repository and update state', () async {
      await notifier.addSong(
        title: 'Yellow',
        artist: 'Coldplay',
        lyrics: 'Look at the stars...',
      );

      final songs = notifier.state.value ?? [];
      expect(songs.length, 1);
      expect(songs.first.title, 'Yellow');
      expect(songs.first.artist, 'Coldplay');
    });

    test('updateLyrics should modify song lyrics', () async {
      await notifier.addSong(
        title: 'Fix You',
        artist: 'Coldplay',
        lyrics: 'When you try your best...',
      );

      final songId = notifier.state.value!.first.id;
      await notifier.updateLyrics(songId, 'Updated lyrics content');

      final updatedSong = await repository.getSongById(songId);
      expect(updatedSong?.lyrics, 'Updated lyrics content');
    });

    test('deleteSong should remove song from state and repository', () async {
      await notifier.addSong(
        title: 'Clocks',
        artist: 'Coldplay',
        lyrics: 'Lights go out...',
      );

      final songId = notifier.state.value!.first.id;
      await notifier.deleteSong(songId);

      final songs = notifier.state.value ?? [];
      expect(songs.isEmpty, isTrue);
    });
  });
}
