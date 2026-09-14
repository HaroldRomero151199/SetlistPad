import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/config/config.dart';
import 'core/navigation/main_navigation_screen.dart';
import 'core/theme/app_theme.dart';
import 'features/playlists/playlists.dart';
import 'features/songs/songs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive local storage
  await Hive.initFlutter();
  Hive.registerAdapter(SongAdapter());
  Hive.registerAdapter(PlaylistAdapter());

  await Hive.openBox<Song>(HiveBoxes.songs);
  await Hive.openBox<Playlist>(HiveBoxes.playlists);

  runApp(
    const ProviderScope(
      child: SetlistPadApp(),
    ),
  );
}

class SetlistPadApp extends StatelessWidget {
  const SetlistPadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SetlistPad',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}
