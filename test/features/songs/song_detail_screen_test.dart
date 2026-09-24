import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setlist_pad/features/songs/songs.dart';
import 'package:setlist_pad/l10n/app_localizations.dart';

class FakeSongRepository implements SongRepository {
  final List<Song> _songs = [];

  @override
  Future<void> deleteSong(String id) async {
    _songs.removeWhere((s) => s.id == id);
  }

  @override
  Future<List<Song>> getAllSongs() async => List.unmodifiable(_songs);

  @override
  Future<Song?> getSongById(String id) async {
    try {
      return _songs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveSong(Song song) async {
    final index = _songs.indexWhere((s) => s.id == song.id);
    if (index >= 0) {
      _songs[index] = song;
    } else {
      _songs.add(song);
    }
  }

  @override
  Future<List<Song>> searchSongs(String query) async {
    final q = query.toLowerCase();
    return _songs.where((s) => s.title.toLowerCase().contains(q) || s.artist.toLowerCase().contains(q)).toList();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeSongRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeSongRepository();
  });

  Widget buildSubject(Song song) {
    return ProviderScope(
      overrides: [
        songRepositoryProvider.overrideWithValue(fakeRepo),
        songsNotifierProvider.overrideWith(() => SongsNotifier(repository: fakeRepo)),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: SongDetailScreen(song: song),
      ),
    );
  }

  testWidgets('renders search lyrics online button when lyrics are empty', (tester) async {
    final now = DateTime.now();
    final song = Song(
      id: 'song-1',
      title: 'In The End',
      artist: 'Linkin Park',
      lyrics: '',
      createdAt: now,
      updatedAt: now,
    );
    await fakeRepo.saveSong(song);

    await tester.pumpWidget(buildSubject(song));
    await tester.pumpAndSettle();

    expect(find.text('In The End'), findsOneWidget);
    expect(find.text('Linkin Park'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.byIcon(Icons.download_rounded), findsOneWidget);
  });

  testWidgets('renders lyrics text when lyrics are present', (tester) async {
    final now = DateTime.now();
    final song = Song(
      id: 'song-2',
      title: 'Yellow',
      artist: 'Coldplay',
      lyrics: 'Look at the stars\nLook how they shine for you',
      createdAt: now,
      updatedAt: now,
    );
    await fakeRepo.saveSong(song);

    await tester.pumpWidget(buildSubject(song));
    await tester.pumpAndSettle();

    expect(find.textContaining('Look at the stars'), findsOneWidget);
  });
}
