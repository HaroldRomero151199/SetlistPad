import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../songs/songs.dart';
import '../../playlists.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  Future<void> _syncPlaylist(
    BuildContext context,
    WidgetRef ref,
    Playlist currentPlaylist,
  ) async {
    final syncingNotifier = ref.read(playlistSyncingProvider.notifier);
    if (ref.read(playlistSyncingProvider).contains(currentPlaylist.id)) return;

    syncingNotifier.setSyncing(currentPlaylist.id, true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;

    try {
      final result = await ref
          .read(playlistsNotifierProvider.notifier)
          .syncPlaylist(currentPlaylist.id);

      final message = PlaylistSyncHelper.formatMessage(l10n, result);
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      debugPrint('Error syncing playlist: $e');
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.errorSyncingPlaylist),
          backgroundColor: colorScheme.error,
        ),
      );
    } finally {
      syncingNotifier.setSyncing(currentPlaylist.id, false);
    }
  }

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
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: songsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                      child: Text(modalContext.l10n.errorPrefix(e.toString()))),
                  data: (allSongs) {
                    final currentPlaylistSongs = ref
                            .watch(playlistsNotifierProvider)
                            .value
                            ?.firstWhere((p) => p.id == playlist.id,
                                orElse: () => playlist)
                            .songIds ??
                        [];

                    final availableSongs = allSongs
                        .where((s) => !currentPlaylistSongs.contains(s.id))
                        .toList();

                    if (availableSongs.isEmpty) {
                      return Center(
                        child: Text(
                          modalContext.l10n.noMoreSongsToAdd,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: modalContext.colorScheme.onSurfaceVariant),
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
                          trailing: Icon(Icons.add_circle_outline,
                              color: modalContext.colorScheme.primary),
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

    final currentPlaylist = playlistsAsync
            .whenData((playlists) => playlists.firstWhere(
                  (p) => p.id == playlist.id,
                  orElse: () => playlist,
                ))
            .value ??
        playlist;

    final allSongsMap = songsAsync.value?.fold<Map<String, Song>>(
          {},
          (map, s) => map..[s.id] = s,
        ) ??
        {};

    final playlistSongs = currentPlaylist.songIds
        .map((id) => allSongsMap[id])
        .whereType<Song>()
        .toList();

    final hasYoutubeUrl = currentPlaylist.youtubePlaylistUrl != null &&
        currentPlaylist.youtubePlaylistUrl!.trim().isNotEmpty;
    final isSyncing =
        ref.watch(playlistSyncingProvider).contains(currentPlaylist.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentPlaylist.name),
        actions: [
          if (hasYoutubeUrl)
            isSyncing
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.sync),
                    tooltip: context.l10n.syncPlaylistTooltip,
                    onPressed: () =>
                        _syncPlaylist(context, ref, currentPlaylist),
                  ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: isSyncing
                  ? context.colorScheme.onSurface.withValues(alpha: 0.38)
                  : context.colorScheme.error,
            ),
            tooltip: context.l10n.deletePlaylistTooltip,
            onPressed: isSyncing
                ? null
                : () {
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
                style: TextStyle(
                    color: context.colorScheme.onSurfaceVariant, fontSize: 14),
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
                      style:
                          TextStyle(color: context.colorScheme.onSurfaceVariant),
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
                          icon: Icon(Icons.remove_circle_outline,
                              color: context.colorScheme.onSurfaceVariant),
                          onPressed: () {
                            ref
                                .read(playlistsNotifierProvider.notifier)
                                .removeSongFromPlaylist(
                                    currentPlaylist.id, song.id);
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
