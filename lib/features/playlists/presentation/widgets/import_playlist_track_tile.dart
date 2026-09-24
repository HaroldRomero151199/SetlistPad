import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/models/youtube_playlist_item.dart';

class ImportPlaylistTrackTile extends StatelessWidget {
  final YouTubePlaylistItem item;
  final int index;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const ImportPlaylistTrackTile({
    super.key,
    required this.item,
    required this.index,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return CheckboxListTile(
      value: isSelected,
      onChanged: onChanged,
      dense: true,
      title: Text(
        item.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
      ),
      subtitle: Text(
        item.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
      ),
      secondary: CircleAvatar(
        radius: 16,
        backgroundColor: isSelected
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        child: Text(
          '${index + 1}',
          style: TextStyle(
            fontSize: 11,
            color: isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
