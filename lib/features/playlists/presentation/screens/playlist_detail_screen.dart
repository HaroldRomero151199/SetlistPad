import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../songs/songs.dart';
import '../../playlists.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  void _showAddSongModal(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.read(songsNotifierProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return Container(
          height: MediaQuery.of(modalContext).size.height * 0.7,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                modalContext.l10n.addSongToPlaylist,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: songsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text(modalContext.l10n.errorPrefix(e.toString()))),
                  data: (allSongs) {
                    final currentPlaylistSongs = ref
                        .watch(playlistsNotifierProvider)
                        .value
                        ?.firstWhere((p) => p.id == playlist.id, orElse: () => playlist)
                        .songIds ?? [];

                    final availableSongs = allSongs
                        .where((s) => !currentPlaylistSongs.contains(s.id))
                        .toList();

                    if (availableSongs.isEmpty) {
                      return Center(
                        child: Text(
                          modalContext.l10n.noMoreSongsToAdd,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: modalContext.colorScheme.onSurfaceVariant),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: availableSongs.length,
                      itemBuilder: (context, index) {
                        final song = availableSongs[index];
                        return ListTile(
                          leading: const Icon(Icons.music_note),
                          title: Text(song.title),
                          subtitle: Text(song.artist),
                          trailing: Icon(Icons.add_circle_outline, color: modalContext.colorScheme.primary),
                          onTap: () {
                            ref
                                .read(playlistsNotifierProvider.notifier)
                                .addSongToPlaylist(playlist.id, song.id);
                            Navigator.of(modalContext).pop();
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsNotifierProvider);
    final songsAsync = ref.watch(songsNotifierProvider);

    final currentPlaylist = playlistsAsync.whenData((playlists) => playlists.firstWhere(
          (p) => p.id == playlist.id,
          orElse: () => playlist,
        )).value ?? playlist;

    final allSongsMap = songsAsync.value?.fold<Map<String, Song>>(
          {},
          (map, s) => map..[s.id] = s,
        ) ?? {};

    final playlistSongs = currentPlaylist.songIds
        .map((id) => allSongsMap[id])
        .whereType<Song>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(currentPlaylist.name),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: context.colorScheme.error),
            tooltip: context.l10n.deletePlaylistTooltip,
            onPressed: () {
              ref
                  .read(playlistsNotifierProvider.notifier)
                  .deletePlaylist(currentPlaylist.id);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentPlaylist.description.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                currentPlaylist.description,
                style: TextStyle(color: context.colorScheme.onSurfaceVariant, fontSize: 14),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.songsCount(playlistSongs.length),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddSongModal(context, ref),
                  icon: const Icon(Icons.add),
                  label: Text(context.l10n.addSong),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: playlistSongs.isEmpty
                ? Center(
                    child: Text(
                      context.l10n.noSongsInPlaylist,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.colorScheme.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    itemCount: playlistSongs.length,
                    itemBuilder: (context, index) {
                      final song = playlistSongs[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: context.colorScheme.primary,
                          foregroundColor: context.colorScheme.onPrimary,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(song.title),
                        subtitle: Text(song.artist),
                        trailing: IconButton(
                          icon: Icon(Icons.remove_circle_outline, color: context.colorScheme.onSurfaceVariant),
                          onPressed: () {
                            ref
                                .read(playlistsNotifierProvider.notifier)
                                .removeSongFromPlaylist(currentPlaylist.id, song.id);
                          },
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SongDetailScreen(song: song),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
