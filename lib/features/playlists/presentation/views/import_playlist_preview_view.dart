import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/models/youtube_playlist_metadata.dart';
import '../widgets/import_playlist_track_tile.dart';

/// View displaying the fetched YouTube playlist items, selection controls, and name editor.
class ImportPlaylistPreviewView extends StatelessWidget {
  final YouTubePlaylistMetadata metadata;
  final Set<int> selectedIndices;
  final TextEditingController playlistNameController;
  final bool createPlaylist;
  final ValueChanged<bool?> onCreatePlaylistChanged;
  final VoidCallback onToggleSelectAll;
  final ValueChanged<int> onToggleItem;
  final String? errorMessage;
  final VoidCallback onCancel;
  final VoidCallback onImport;

  const ImportPlaylistPreviewView({
    super.key,
    required this.metadata,
    required this.selectedIndices,
    required this.playlistNameController,
    required this.createPlaylist,
    required this.onCreatePlaylistChanged,
    required this.onToggleSelectAll,
    required this.onToggleItem,
    required this.errorMessage,
    required this.onCancel,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final allSelected = selectedIndices.length == metadata.items.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(Icons.playlist_play, color: colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.playlistPreviewTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    metadata.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          value: createPlaylist,
          onChanged: onCreatePlaylistChanged,
          title: Text(
            context.l10n.createPlaylistWithSongs,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        if (createPlaylist) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TextField(
              controller: playlistNameController,
              decoration: InputDecoration(
                labelText: context.l10n.playlistName,
                isDense: true,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.songsCount(selectedIndices.length),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            TextButton.icon(
              onPressed: onToggleSelectAll,
              icon: Icon(
                allSelected ? Icons.deselect : Icons.select_all,
                size: 16,
              ),
              label: Text(
                allSelected ? context.l10n.deselectAll : context.l10n.selectAll,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        const Divider(height: 8),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: metadata.items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = metadata.items[index];
              final isSelected = selectedIndices.contains(index);

              return ImportPlaylistTrackTile(
                item: item,
                index: index,
                isSelected: isSelected,
                onChanged: (_) => onToggleItem(index),
              );
            },
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            errorMessage!,
            style: TextStyle(color: colorScheme.error, fontSize: 12),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: onCancel,
              child: Text(context.l10n.cancel),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: selectedIndices.isEmpty ? null : onImport,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text(
                context.l10n.importSelectedSongs(selectedIndices.length),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
