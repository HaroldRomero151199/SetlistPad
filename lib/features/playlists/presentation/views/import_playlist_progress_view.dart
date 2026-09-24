import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// View presenting real-time progress while playlist songs are being imported.
class ImportPlaylistProgressView extends StatelessWidget {
  final int current;
  final int total;
  final VoidCallback onHideDialog;

  const ImportPlaylistProgressView({
    super.key,
    required this.current,
    required this.total,
    required this.onHideDialog,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final progress = total > 0 ? current / total : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Icon(Icons.cloud_download, color: colorScheme.primary, size: 48),
        const SizedBox(height: 16),
        Text(
          context.l10n.importingSongProgress(current, total),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: colorScheme.surfaceContainerHighest,
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: onHideDialog,
          child: Text(context.l10n.hideDialog),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
