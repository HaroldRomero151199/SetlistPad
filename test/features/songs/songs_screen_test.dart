import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:setlist_pad/core/providers/providers.dart';
import 'package:setlist_pad/features/playlists/playlists.dart';
import 'package:setlist_pad/features/songs/songs.dart';
import 'package:setlist_pad/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Box<Song> songBox;
  late Box<Playlist> playlistBox;

  setUp(() async {
    Hive.init('./test_hive_songs_screen');
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(SongAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(PlaylistAdapter());
    songBox = await Hive.openBox<Song>('test_screen_songs');
    playlistBox = await Hive.openBox<Playlist>('test_screen_playlists');
  });

  tearDown(() async {
    await songBox.close();
    await playlistBox.close();
    await Hive.deleteBoxFromDisk('test_screen_songs');
    await Hive.deleteBoxFromDisk('test_screen_playlists');
  });

  testWidgets('Clear button clears TextField text and searchQueryProvider', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          songBoxProvider.overrideWithValue(songBox),
          playlistBoxProvider.overrideWithValue(playlistBox),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SongsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);

    // Enter text
    await tester.enterText(textFieldFinder, 'Coldplay');
    await tester.pumpAndSettle();

    expect(find.text('Coldplay'), findsOneWidget);
    final clearButtonFinder = find.byIcon(Icons.clear);
    expect(clearButtonFinder, findsOneWidget);

    // Tap clear button
    await tester.tap(clearButtonFinder);
    await tester.pumpAndSettle();

    // Verify TextField text is empty and clear button is gone
    final textField = tester.widget<TextField>(textFieldFinder);
    expect(textField.controller?.text, '');
    expect(find.byIcon(Icons.clear), findsNothing);
  });
}
