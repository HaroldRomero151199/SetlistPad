import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setlist_pad/features/playlists/playlists.dart';
import 'package:setlist_pad/l10n/app_localizations.dart';
import '../../../fakes/fake_playlist_repository.dart';

void main() {
  late FakePlaylistRepository fakePlaylistRepo;

  setUp(() {
    fakePlaylistRepo = FakePlaylistRepository();
  });

  Widget buildSubject({Locale locale = const Locale('es')}) {
    return ProviderScope(
      overrides: [
        playlistRepositoryProvider.overrideWithValue(fakePlaylistRepo),
        playlistsNotifierProvider.overrideWith(
          () => PlaylistsNotifier(repository: fakePlaylistRepo),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const PlaylistsScreen(),
      ),
    );
  }

  group('PlaylistsScreen Delete Confirmation Tests', () {
    testWidgets('canceling playlist deletion keeps playlist intact', (
      tester,
    ) async {
      final now = DateTime.now();
      await fakePlaylistRepo.savePlaylist(
        Playlist(
          id: 'pl-1',
          name: 'Sunday Acoustic',
          songIds: const [],
          createdAt: now,
          updatedAt: now,
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Sunday Acoustic'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Eliminar lista de reproducción'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Sunday Acoustic'), findsOneWidget);
      expect(await fakePlaylistRepo.getPlaylistById('pl-1'), isNotNull);
    });

    testWidgets(
      'confirming playlist deletion deletes playlist and shows SnackBar',
      (tester) async {
        final now = DateTime.now();
        await fakePlaylistRepo.savePlaylist(
          Playlist(
            id: 'pl-2',
            name: 'Sunday Acoustic',
            songIds: const [],
            createdAt: now,
            updatedAt: now,
          ),
        );

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text('Sunday Acoustic'), findsNothing);
        expect(
          find.text('Se eliminó la lista "Sunday Acoustic"'),
          findsOneWidget,
        );
        expect(await fakePlaylistRepo.getPlaylistById('pl-2'), isNull);
      },
    );
  });
}
