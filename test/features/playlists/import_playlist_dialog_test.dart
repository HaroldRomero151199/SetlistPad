import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setlist_pad/core/services/models/youtube_playlist_item.dart';
import 'package:setlist_pad/core/services/models/youtube_playlist_metadata.dart';
import 'package:setlist_pad/features/playlists/presentation/widgets/import_playlist_dialog.dart';
import 'package:setlist_pad/l10n/app_localizations.dart';

Widget createWidgetUnderTest(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('ImportPlaylistDialog Widget Tests', () {
    testWidgets('renders preview with tracks when initialMetadata is provided', (tester) async {
      final sampleMetadata = YouTubePlaylistMetadata(
        id: 'PLTest999',
        title: 'Awesome Gig Setlist',
        author: 'BandChannel',
        items: [
          YouTubePlaylistItem(
            videoId: 'v1',
            title: 'Song One',
            artist: 'Band A',
            rawTitle: 'Band A - Song One',
            url: 'https://youtube.com/watch?v=v1',
          ),
          YouTubePlaylistItem(
            videoId: 'v2',
            title: 'Song Two',
            artist: 'Band B',
            rawTitle: 'Band B - Song Two',
            url: 'https://youtube.com/watch?v=v2',
          ),
        ],
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          ImportPlaylistDialog(initialMetadata: sampleMetadata),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Awesome Gig Setlist'), findsNWidgets(2)); // Header + TextField default
      expect(find.text('Song One'), findsOneWidget);
      expect(find.text('Song Two'), findsOneWidget);
      expect(find.text('Band A'), findsOneWidget);
      expect(find.text('Band B'), findsOneWidget);
    });

    testWidgets('toggling Select All selects and deselects all tracks', (tester) async {
      final sampleMetadata = YouTubePlaylistMetadata(
        id: 'PLTest999',
        title: 'Awesome Gig Setlist',
        items: [
          YouTubePlaylistItem(
            videoId: 'v1',
            title: 'Song One',
            artist: 'Band A',
            rawTitle: 'Song One',
            url: 'https://youtube.com/watch?v=v1',
          ),
        ],
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          ImportPlaylistDialog(initialMetadata: sampleMetadata),
        ),
      );
      await tester.pumpAndSettle();

      // Initially all selected
      expect(find.text('Deselect All'), findsOneWidget);

      // Tap deselect all
      await tester.tap(find.text('Deselect All'));
      await tester.pumpAndSettle();

      expect(find.text('Select All'), findsOneWidget);
    });
    testWidgets('duplicate tracks can be selected and deselected independently by index', (tester) async {
      final sampleMetadata = YouTubePlaylistMetadata(
        id: 'PLDupTest',
        title: 'Duplicate Tracks Playlist',
        items: [
          YouTubePlaylistItem(
            videoId: 'v1',
            title: 'Song One',
            artist: 'Band A',
            rawTitle: 'Song One',
            url: 'https://youtube.com/watch?v=v1',
          ),
          YouTubePlaylistItem(
            videoId: 'v1',
            title: 'Song One Reprise',
            artist: 'Band A',
            rawTitle: 'Song One Reprise',
            url: 'https://youtube.com/watch?v=v1',
          ),
        ],
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          ImportPlaylistDialog(initialMetadata: sampleMetadata),
        ),
      );
      await tester.pumpAndSettle();

      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsNWidgets(3));

      expect(find.text('2 Songs'), findsOneWidget);

      // Tap first item checkbox
      await tester.tap(checkboxes.at(1));
      await tester.pumpAndSettle();

      // Only one item remains selected, proving independence
      expect(find.text('1 Song'), findsOneWidget);
    });
  });
}