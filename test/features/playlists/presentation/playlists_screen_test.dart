import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setlist_pad/features/playlists/playlists.dart';
import 'package:setlist_pad/l10n/app_localizations.dart';

class _FakePlaylistRepository implements PlaylistRepository {
  final List<Playlist> playlists = [];

  @override
  Future<List<Playlist>> getAllPlaylists() async => List.unmodifiable(playlists);

  @override
  Future<Playlist?> getPlaylistById(String id) async {
    try {
      return playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> savePlaylist(Playlist playlist) async {
    playlists.removeWhere((p) => p.id == playlist.id);
    playlists.add(playlist);
  }

  @override
  Future<void> deletePlaylist(String id) async {
    playlists.removeWhere((p) => p.id == id);
  }

  @override
  Future<void> addSongToPlaylist(String playlistId, String songId) async {}

  @override
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {}

  @override
  Future<void> removeSongFromAllPlaylists(String songId) async {}
}

void main() {
  late _FakePlaylistRepository fakePlaylistRepo;

  setUp(() {
    fakePlaylistRepo = _FakePlaylistRepository();
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

    testWidgets('confirming playlist deletion deletes playlist and shows SnackBar', (
      tester,
    ) async {
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
    });
  });
}
