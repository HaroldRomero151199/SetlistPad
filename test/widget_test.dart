import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:setlist_pad/core/providers/providers.dart';
import 'package:setlist_pad/features/playlists/playlists.dart';
import 'package:setlist_pad/features/songs/songs.dart';
import 'package:setlist_pad/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Box<Song> songBox;
  late Box<Playlist> playlistBox;

  setUp(() async {
    Hive.init('./test_hive_widget');
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(SongAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(PlaylistAdapter());
    songBox = await Hive.openBox<Song>('test_widget_songs');
    playlistBox = await Hive.openBox<Playlist>('test_widget_playlists');
  });

  tearDown(() async {
    await songBox.close();
    await playlistBox.close();
    await Hive.deleteBoxFromDisk('test_widget_songs');
    await Hive.deleteBoxFromDisk('test_widget_playlists');
  });

  testWidgets('SetlistPadApp initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          songBoxProvider.overrideWithValue(songBox),
          playlistBoxProvider.overrideWithValue(playlistBox),
        ],
        child: const SetlistPadApp(),
      ),
    );

    expect(find.text('Playlists'), findsWidgets);
  });
}
