import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'SetlistPad'**
  String get appTitle;

  /// Title displayed on the home screen app bar
  ///
  /// In en, this message translates to:
  /// **'SetlistPad'**
  String get homeTitle;

  /// Status text indicating core initialization
  ///
  /// In en, this message translates to:
  /// **'SetlistPad Core Initialized'**
  String get coreInitialized;

  /// Subtitle indicating database and state management status
  ///
  /// In en, this message translates to:
  /// **'Hive DB & Riverpod ready for Playlists and Songs'**
  String get hiveRiverpodReady;

  /// Label for the Playlists bottom navigation destination
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get navPlaylists;

  /// Label for the Song Library bottom navigation destination
  ///
  /// In en, this message translates to:
  /// **'Song Library'**
  String get navSongLibrary;

  /// Title of the Playlists screen app bar
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlistsTitle;

  /// Dialog title for creating a new playlist
  ///
  /// In en, this message translates to:
  /// **'Create New Playlist'**
  String get createNewPlaylist;

  /// Label for the playlist name text field
  ///
  /// In en, this message translates to:
  /// **'Playlist Name'**
  String get playlistName;

  /// Hint for the playlist name text field
  ///
  /// In en, this message translates to:
  /// **'e.g. Saturday Gig Setlist'**
  String get playlistNameHint;

  /// Validation error when playlist name is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get playlistNameRequired;

  /// Label for optional playlist description
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// Generic cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Create button text
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Placeholder text when no playlists exist
  ///
  /// In en, this message translates to:
  /// **'No playlists yet'**
  String get noPlaylistsYet;

  /// Call to action text when no playlists exist
  ///
  /// In en, this message translates to:
  /// **'Tap + to create a playlist'**
  String get tapToCreatePlaylist;

  /// Label for the New Playlist floating action button
  ///
  /// In en, this message translates to:
  /// **'New Playlist'**
  String get newPlaylist;

  /// Pluralized count of songs
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Song} other{{count} Songs}}'**
  String songsCount(num count);

  /// Button to add a song to playlist
  ///
  /// In en, this message translates to:
  /// **'Add Song'**
  String get addSong;

  /// Title of modal to add a song to playlist
  ///
  /// In en, this message translates to:
  /// **'Add Song to Playlist'**
  String get addSongToPlaylist;

  /// Message shown when all library songs are already in the playlist
  ///
  /// In en, this message translates to:
  /// **'No more songs available to add.\nImport more songs in the Library tab.'**
  String get noMoreSongsToAdd;

  /// Message shown when a playlist is currently empty
  ///
  /// In en, this message translates to:
  /// **'No songs in this playlist yet.\nTap \"Add Song\" to add songs from your library.'**
  String get noSongsInPlaylist;

  /// Tooltip for delete playlist action button
  ///
  /// In en, this message translates to:
  /// **'Delete Playlist'**
  String get deletePlaylistTooltip;

  /// Title of the Song Library screen app bar
  ///
  /// In en, this message translates to:
  /// **'Song Library'**
  String get songLibraryTitle;

  /// Hint text for song search input
  ///
  /// In en, this message translates to:
  /// **'Search title or artist...'**
  String get searchHint;

  /// Placeholder text when song library is empty or search yields no results
  ///
  /// In en, this message translates to:
  /// **'No songs found in library'**
  String get noSongsFound;

  /// Call to action text when song library is empty
  ///
  /// In en, this message translates to:
  /// **'Tap + to import from YouTube'**
  String get tapToImport;

  /// Label for the import YouTube floating action button
  ///
  /// In en, this message translates to:
  /// **'Import YouTube'**
  String get importYoutube;

  /// Title of the import YouTube dialog
  ///
  /// In en, this message translates to:
  /// **'Import from YouTube'**
  String get importFromYoutube;

  /// Explanation text in import YouTube dialog
  ///
  /// In en, this message translates to:
  /// **'Paste a YouTube video link. Title, artist, and lyrics (via LRCLIB) will be fetched automatically.'**
  String get importYoutubeDescription;

  /// Label for YouTube URL input field
  ///
  /// In en, this message translates to:
  /// **'YouTube URL'**
  String get youtubeUrl;

  /// Hint text for YouTube URL input field
  ///
  /// In en, this message translates to:
  /// **'https://www.youtube.com/watch?v=...'**
  String get youtubeUrlHint;

  /// Validation error when URL is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a URL'**
  String get pleaseEnterUrl;

  /// Validation error when URL is not a recognized YouTube URL
  ///
  /// In en, this message translates to:
  /// **'Must be a valid YouTube URL'**
  String get invalidYoutubeUrl;

  /// Loading text while fetching song details
  ///
  /// In en, this message translates to:
  /// **'Fetching metadata & lyrics...'**
  String get fetchingMetadata;

  /// Button to trigger import action
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importButton;

  /// Success message when a song is imported
  ///
  /// In en, this message translates to:
  /// **'Imported \"{title}\" by {artist}'**
  String songImportedSuccess(String title, String artist);

  /// Tooltip for edit lyrics button
  ///
  /// In en, this message translates to:
  /// **'Edit Lyrics'**
  String get editLyrics;

  /// Tooltip for save lyrics button
  ///
  /// In en, this message translates to:
  /// **'Save Lyrics'**
  String get saveLyrics;

  /// Snackbar message when lyrics are saved
  ///
  /// In en, this message translates to:
  /// **'Lyrics updated successfully!'**
  String get lyricsUpdatedSuccess;

  /// Label for text size slider control
  ///
  /// In en, this message translates to:
  /// **'Text Size:'**
  String get textSize;

  /// Hint text when editing song lyrics
  ///
  /// In en, this message translates to:
  /// **'Enter or edit lyrics here...'**
  String get lyricsHint;

  /// Placeholder text when song has no lyrics
  ///
  /// In en, this message translates to:
  /// **'No lyrics available for this song. Tap edit icon above to add lyrics.'**
  String get noLyricsAvailable;

  /// Prefix for displaying error messages
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorPrefix(String error);

  /// Error message displayed when song import fails
  ///
  /// In en, this message translates to:
  /// **'Failed to import song. Please check the URL and your connection.'**
  String get errorImportingSong;

  /// Error message displayed when YouTube URL format is invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid YouTube video URL format.'**
  String get errorInvalidYoutubeUrlFormat;

  /// Button label for importing a playlist
  ///
  /// In en, this message translates to:
  /// **'Import Playlist'**
  String get importPlaylist;

  /// Title of the YouTube playlist import dialog
  ///
  /// In en, this message translates to:
  /// **'Import YouTube Playlist'**
  String get importFromYoutubePlaylist;

  /// Description in the YouTube playlist import dialog
  ///
  /// In en, this message translates to:
  /// **'Paste a YouTube playlist link to preview and import its songs.'**
  String get importYoutubePlaylistDescription;

  /// Label for YouTube playlist URL input
  ///
  /// In en, this message translates to:
  /// **'YouTube Playlist URL'**
  String get youtubePlaylistUrl;

  /// Hint text for YouTube playlist URL input
  ///
  /// In en, this message translates to:
  /// **'https://www.youtube.com/playlist?list=...'**
  String get youtubePlaylistUrlHint;

  /// Loading indicator text while fetching playlist
  ///
  /// In en, this message translates to:
  /// **'Fetching playlist tracks...'**
  String get fetchingPlaylist;

  /// Title of the playlist preview dialog
  ///
  /// In en, this message translates to:
  /// **'Playlist Preview'**
  String get playlistPreviewTitle;

  /// Button label to select all playlist items
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// Button label to deselect all playlist items
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// Option checkbox to create a playlist with the imported songs
  ///
  /// In en, this message translates to:
  /// **'Create new playlist with selected songs'**
  String get createPlaylistWithSongs;

  /// Button text to import selected count of songs
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Import 1 Song} other{Import {count} Songs}}'**
  String importSelectedSongs(num count);

  /// Progress label during batch song import
  ///
  /// In en, this message translates to:
  /// **'Importing {current} of {total}...'**
  String importingSongProgress(int current, int total);

  /// Success message when playlist songs are imported
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Imported 1 song from playlist} other{Imported {count} songs from playlist}}'**
  String playlistImportSuccess(num count);

  /// Error message when playlist has no tracks
  ///
  /// In en, this message translates to:
  /// **'The playlist is empty, private, or could not be loaded.'**
  String get errorPlaylistEmpty;

  /// Error message when playlist fetching fails
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch playlist tracks. Please check the URL and your connection.'**
  String get errorFetchingPlaylist;

  /// Error message when playlist URL is invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid YouTube playlist URL.'**
  String get errorInvalidPlaylistUrl;

  /// Button label to search lyrics online for a song
  ///
  /// In en, this message translates to:
  /// **'Search Lyrics Online'**
  String get searchLyricsOnline;

  /// Loading state text while searching for lyrics online
  ///
  /// In en, this message translates to:
  /// **'Searching lyrics...'**
  String get searchingLyrics;

  /// Success message when online lyrics are found and updated
  ///
  /// In en, this message translates to:
  /// **'Lyrics found and updated!'**
  String get lyricsFoundSuccess;

  /// Message when online lyrics search yields no result
  ///
  /// In en, this message translates to:
  /// **'No lyrics found online for this song.'**
  String get noLyricsFoundOnline;

  /// Error message when creating a playlist with a duplicate name
  ///
  /// In en, this message translates to:
  /// **'A playlist with this name already exists'**
  String get playlistAlreadyExists;

  /// Button to dismiss import dialog while letting import finish in background
  ///
  /// In en, this message translates to:
  /// **'Run in background'**
  String get hideDialog;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
