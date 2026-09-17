// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SetlistPad';

  @override
  String get homeTitle => 'SetlistPad';

  @override
  String get coreInitialized => 'SetlistPad Core Initialized';

  @override
  String get hiveRiverpodReady =>
      'Hive DB & Riverpod ready for Playlists and Songs';

  @override
  String get navPlaylists => 'Playlists';

  @override
  String get navSongLibrary => 'Song Library';

  @override
  String get playlistsTitle => 'Playlists';

  @override
  String get createNewPlaylist => 'Create New Playlist';

  @override
  String get playlistName => 'Playlist Name';

  @override
  String get playlistNameHint => 'e.g. Saturday Gig Setlist';

  @override
  String get playlistNameRequired => 'Please enter a name';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get noPlaylistsYet => 'No playlists yet';

  @override
  String get tapToCreatePlaylist => 'Tap + to create a playlist';

  @override
  String get newPlaylist => 'New Playlist';

  @override
  String songsCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Songs',
      one: '1 Song',
    );
    return '$_temp0';
  }

  @override
  String get addSong => 'Add Song';

  @override
  String get addSongToPlaylist => 'Add Song to Playlist';

  @override
  String get noMoreSongsToAdd =>
      'No more songs available to add.\nImport more songs in the Library tab.';

  @override
  String get noSongsInPlaylist =>
      'No songs in this playlist yet.\nTap \"Add Song\" to add songs from your library.';

  @override
  String get deletePlaylistTooltip => 'Delete Playlist';

  @override
  String get songLibraryTitle => 'Song Library';

  @override
  String get searchHint => 'Search title or artist...';

  @override
  String get noSongsFound => 'No songs found in library';

  @override
  String get tapToImport => 'Tap + to import from YouTube';

  @override
  String get importYoutube => 'Import YouTube';

  @override
  String get importFromYoutube => 'Import from YouTube';

  @override
  String get importYoutubeDescription =>
      'Paste a YouTube video link. Title, artist, and lyrics (via LRCLIB) will be fetched automatically.';

  @override
  String get youtubeUrl => 'YouTube URL';

  @override
  String get youtubeUrlHint => 'https://www.youtube.com/watch?v=...';

  @override
  String get pleaseEnterUrl => 'Please enter a URL';

  @override
  String get invalidYoutubeUrl => 'Must be a valid YouTube URL';

  @override
  String get fetchingMetadata => 'Fetching metadata & lyrics...';

  @override
  String get importButton => 'Import';

  @override
  String songImportedSuccess(String title, String artist) {
    return 'Imported \"$title\" by $artist';
  }

  @override
  String get editLyrics => 'Edit Lyrics';

  @override
  String get saveLyrics => 'Save Lyrics';

  @override
  String get lyricsUpdatedSuccess => 'Lyrics updated successfully!';

  @override
  String get textSize => 'Text Size:';

  @override
  String get lyricsHint => 'Enter or edit lyrics here...';

  @override
  String get noLyricsAvailable =>
      'No lyrics available for this song. Tap edit icon above to add lyrics.';

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get errorImportingSong =>
      'Failed to import song. Please check the URL and your connection.';

  @override
  String get errorInvalidYoutubeUrlFormat =>
      'Invalid YouTube video URL format.';
}
