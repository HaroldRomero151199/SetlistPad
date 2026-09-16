import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/songs_notifier.dart';
import '../widgets/import_song_dialog.dart';
import 'song_detail_screen.dart';

class SongsScreen extends ConsumerWidget {
  const SongsScreen({super.key});

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ImportSongDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredSongsAsync = ref.watch(filteredSongsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.songLibraryTitle),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (val) {
                ref.read(searchQueryProvider.notifier).query = val;
              },
              decoration: InputDecoration(
                hintText: context.l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Consumer(
                  builder: (context, ref, _) {
                    final query = ref.watch(searchQueryProvider);
                    if (query.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        ref.read(searchQueryProvider.notifier).query = '';
                      },
                    );
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Songs list
          Expanded(
            child: filteredSongsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) =>
                  Center(child: Text(context.l10n.errorPrefix(err.toString()))),
              data: (songs) {
                if (songs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_off,
                          size: 48,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.l10n.noSongsFound,
                          style: TextStyle(
                            fontSize: 16,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.tapToImport,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: context.colorScheme.primary,
                          child: Icon(
                            Icons.music_note,
                            color: context.colorScheme.onPrimary,
                          ),
                        ),
                        title: Text(
                          song.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Row(
                          children: [
                            Text(song.artist),
                            if (song.youtubeUrl != null) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.play_circle_fill,
                                size: 14,
                                color: context.colorScheme.error,
                              ),
                            ],
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            ref
                                .read(songsNotifierProvider.notifier)
                                .deleteSong(song.id);
                          },
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SongDetailScreen(song: song),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'songs_fab',
        onPressed: () => _showImportDialog(context),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.importYoutube),
      ),
    );
  }
}
