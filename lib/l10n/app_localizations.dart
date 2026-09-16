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
