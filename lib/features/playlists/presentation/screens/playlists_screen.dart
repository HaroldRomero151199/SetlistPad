import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/playlists_notifier.dart';
import '../widgets/import_playlist_dialog.dart';
import 'playlist_detail_screen.dart';

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  void _showCreatePlaylistDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(dialogContext.l10n.createNewPlaylist),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: dialogContext.l10n.playlistName,
                    hintText: dialogContext.l10n.playlistNameHint,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return dialogContext.l10n.playlistNameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: dialogContext.l10n.descriptionOptional,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(dialogContext.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  ref.read(playlistsNotifierProvider.notifier).createPlaylist(
                        name: nameController.text.trim(),
                        description: descController.text.trim(),
                      );
                  Navigator.of(dialogContext).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: dialogContext.colorScheme.primary,
                foregroundColor: dialogContext.colorScheme.onPrimary,
              ),
              child: Text(dialogContext.l10n.create),
            ),
          ],
        );
      },
    );
  }

  void _showImportPlaylistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const ImportPlaylistDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.playlistsTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_play),
            tooltip: context.l10n.importFromYoutubePlaylist,
            onPressed: () => _showImportPlaylistDialog(context),
          ),
        ],
      ),
      body: playlistsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(context.l10n.errorPrefix(err.toString()))),
        data: (playlists) {
          if (playlists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.playlist_add, size: 48, color: context.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.noPlaylistsYet,
                    style: TextStyle(fontSize: 16, color: context.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.tapToCreatePlaylist,
                    style: TextStyle(fontSize: 12, color: context.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: context.colorScheme.primary,
                    child: Icon(Icons.queue_music, color: context.colorScheme.onPrimary),
                  ),
                  title: Text(
                    playlist.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Row(
                    children: [
                      Text(context.l10n.songsCount(playlist.songIds.length)),
                      if (playlist.description.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '• ${playlist.description}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: context.colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: context.colorScheme.onSurfaceVariant),
                    onPressed: () {
                      ref
                          .read(playlistsNotifierProvider.notifier)
                          .deletePlaylist(playlist.id);
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PlaylistDetailScreen(playlist: playlist),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'playlists_fab',
        onPressed: () => _showCreatePlaylistDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.newPlaylist),
      ),
    );
  }
}
