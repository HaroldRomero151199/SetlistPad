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
}
