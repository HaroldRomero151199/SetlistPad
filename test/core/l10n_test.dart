import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setlist_pad/l10n/app_localizations.dart';

void main() {
  group('AppLocalizations Tests', () {
    test('English translations are loaded and correct', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      expect(l10n.appTitle, 'SetlistPad');
      expect(l10n.navPlaylists, 'Playlists');
      expect(l10n.navSongLibrary, 'Song Library');
      expect(l10n.newPlaylist, 'New Playlist');
      expect(l10n.songsCount(1), '1 Song');
      expect(l10n.songsCount(5), '5 Songs');
      expect(l10n.songImportedSuccess('SongA', 'ArtistB'), 'Imported "SongA" by ArtistB');
    });

    test('Spanish translations are loaded and correct', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      expect(l10n.appTitle, 'SetlistPad');
      expect(l10n.navPlaylists, 'Listas');
      expect(l10n.navSongLibrary, 'Biblioteca');
      expect(l10n.newPlaylist, 'Nueva lista');
      expect(l10n.songsCount(1), '1 Canción');
      expect(l10n.songsCount(5), '5 Canciones');
      expect(l10n.songImportedSuccess('SongA', 'ArtistB'), 'Se importó "SongA" de ArtistB');
    });
  });
}
