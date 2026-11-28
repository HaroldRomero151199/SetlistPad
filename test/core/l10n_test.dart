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
      expect(l10n.delete, 'Delete');
      expect(l10n.undo, 'Undo');
      expect(l10n.removeSongFromPlaylistTooltip, 'Remove song from playlist');
      expect(l10n.removeSongFromPlaylistTitle, 'Remove Song from Playlist');
      expect(
        l10n.removeSongFromPlaylistMessage('Bohemian Rhapsody'),
        'Are you sure you want to remove "Bohemian Rhapsody" from this playlist?',
      );
      expect(l10n.deletePlaylistTitle, 'Delete Playlist');
      expect(
        l10n.deletePlaylistMessage('Saturday Gig'),
        'Are you sure you want to delete "Saturday Gig"? This action cannot be undone.',
      );
      expect(
        l10n.songRemovedFromPlaylist('Bohemian Rhapsody'),
        'Removed "Bohemian Rhapsody" from playlist',
      );
      expect(
        l10n.playlistDeleted('Saturday Gig'),
        'Deleted playlist "Saturday Gig"',
      );
      expect(l10n.deleteSongTooltip, 'Delete Song');
      expect(l10n.deleteSongTitle, 'Delete Song');
      expect(
        l10n.deleteSongMessage('Bohemian Rhapsody'),
        'Are you sure you want to delete "Bohemian Rhapsody" from your library? It will also be removed from all playlists.',
      );
      expect(
        l10n.songDeleted('Bohemian Rhapsody'),
        'Deleted "Bohemian Rhapsody" from library',
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
      expect(l10n.delete, 'Eliminar');
      expect(l10n.undo, 'Deshacer');
      expect(l10n.removeSongFromPlaylistTooltip, 'Eliminar canción de la lista');
      expect(l10n.removeSongFromPlaylistTitle, 'Eliminar canción de la lista');
      expect(
        l10n.removeSongFromPlaylistMessage('Bohemian Rhapsody'),
        '¿Estás seguro de que deseas eliminar "Bohemian Rhapsody" de esta lista de reproducción?',
      );
      expect(l10n.deletePlaylistTitle, 'Eliminar lista de reproducción');
      expect(
        l10n.deletePlaylistMessage('Concierto'),
        '¿Estás seguro de que deseas eliminar "Concierto"? Esta acción no se puede deshacer.',
      );
      expect(
        l10n.songRemovedFromPlaylist('Bohemian Rhapsody'),
        'Se eliminó "Bohemian Rhapsody" de la lista',
      );
      expect(
        l10n.playlistDeleted('Concierto'),
        'Se eliminó la lista "Concierto"',
      );
      expect(l10n.deleteSongTooltip, 'Eliminar canción');
      expect(l10n.deleteSongTitle, 'Eliminar canción');
      expect(
        l10n.deleteSongMessage('Bohemian Rhapsody'),
        '¿Estás seguro de que deseas eliminar "Bohemian Rhapsody" de tu biblioteca? También se quitará de todas las listas de reproducción.',
      );
      expect(
        l10n.songDeleted('Bohemian Rhapsody'),
        'Se eliminó "Bohemian Rhapsody" de la biblioteca',
      );
    });
  });
}
