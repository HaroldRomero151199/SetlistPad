import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:setlist_pad/features/playlists/playlists.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Box<Playlist> playlistBox;
  late PlaylistRepository repository;
  late ProviderContainer container;
  late PlaylistsNotifier notifier;

  setUp(() async {
    Hive.init('./test_hive_playlists_notifier');
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PlaylistAdapter());
    }
    playlistBox = await Hive.openBox<Playlist>('test_playlists_box');
    await playlistBox.clear();

    repository = HivePlaylistRepository(playlistBox: playlistBox);

    container = ProviderContainer(
      overrides: [
        playlistRepositoryProvider.overrideWithValue(repository),
      ],
    );

    notifier = container.read(playlistsNotifierProvider.notifier);
  });

  tearDown(() async {
    container.dispose();
    await playlistBox.close();
    await Hive.deleteBoxFromDisk('test_playlists_box');
  });

  group('PlaylistsNotifier Tests', () {
    test('createPlaylist should store a new playlist in Hive and state', () async {
      final playlist = await notifier.createPlaylist(
        name: 'Saturday Gig',
        description: 'Rock songs',
      );

      final list = notifier.state.value ?? [];
      expect(list.length, 1);
      expect(list.first.id, playlist.id);
      expect(list.first.name, 'Saturday Gig');
    });

    test('addSongToPlaylist & removeSongFromPlaylist should update playlist songIds', () async {
      final playlist = await notifier.createPlaylist(
        name: 'Acoustic Set',
      );

      await notifier.addSongToPlaylist(playlist.id, 'song-101');
      var updated = await repository.getPlaylistById(playlist.id);
      expect(updated?.songIds, ['song-101']);

      await notifier.removeSongFromPlaylist(playlist.id, 'song-101');
      updated = await repository.getPlaylistById(playlist.id);
      expect(updated?.songIds.isEmpty, isTrue);
    });
  });
}
