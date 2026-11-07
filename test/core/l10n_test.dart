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
      expect(l10n.errorImportingSong, 'Failed to import song. Please check the URL and your connection.');
      expect(l10n.errorInvalidYoutubeUrlFormat, 'Invalid YouTube video URL format.');
      expect(l10n.syncPlaylistTooltip, 'Sync playlist');
      expect(l10n.syncResultAddedAndRemoved(1, 1), '+1 added, -1 removed');
      expect(l10n.syncResultAdded(2), '+2 added');
      expect(l10n.syncResultRemoved(1), '-1 removed');
      expect(l10n.syncResultNoChanges, 'Playlist is already up to date');
      expect(l10n.errorSyncingPlaylist, 'Failed to sync playlist. Please check the URL and your connection.');
      expect(
        l10n.errorSingleVideoNotPlaylist,
        'This link is for a single song, not a playlist. You can import it from the Library tab.',
      );
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
      expect(l10n.errorImportingSong, 'No se pudo importar la canción. Verifica el enlace y tu conexión.');
      expect(l10n.errorInvalidYoutubeUrlFormat, 'Formato de URL de YouTube no válido.');
      expect(l10n.syncPlaylistTooltip, 'Sincronizar lista');
      expect(l10n.syncResultAddedAndRemoved(1, 1), '+1 añadida, -1 removida');
      expect(l10n.syncResultAdded(2), '+2 añadidas');
      expect(l10n.syncResultRemoved(1), '-1 removida');
      expect(l10n.syncResultNoChanges, 'La lista ya está actualizada');
      expect(l10n.errorSyncingPlaylist, 'No se pudo sincronizar la lista. Verifica el enlace y tu conexión.');
      expect(
        l10n.errorSingleVideoNotPlaylist,
        'Este enlace es de una canción individual, no de una lista de reproducción. Puedes importarla desde la pestaña Biblioteca.',
      );
    });
  });
}
