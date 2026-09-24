import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// View presenting the URL input form for importing YouTube playlists.
class ImportPlaylistUrlView extends StatelessWidget {
  final TextEditingController urlController;
  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const ImportPlaylistUrlView({
    super.key,
    required this.urlController,
    required this.formKey,
    required this.isLoading,
    required this.errorMessage,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.playlist_play, color: colorScheme.error, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.importFromYoutubePlaylist,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.importYoutubePlaylistDescription,
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Form(
          key: formKey,
          child: TextFormField(
            controller: urlController,
            enabled: !isLoading,
            decoration: InputDecoration(
              labelText: context.l10n.youtubePlaylistUrl,
              hintText: context.l10n.youtubePlaylistUrlHint,
              prefixIcon: const Icon(Icons.link),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return context.l10n.pleaseEnterUrl;
              }
              if (!value.contains('youtube.com') &&
                  !value.contains('youtu.be')) {
                return context.l10n.invalidYoutubeUrl;
              }
              return null;
            },
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            errorMessage!,
            style: TextStyle(color: colorScheme.error, fontSize: 12),
          ),
        ],
        if (isLoading) ...[
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 10),
                Text(
                  context.l10n.fetchingPlaylist,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: isLoading ? null : onCancel,
              child: Text(context.l10n.cancel),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text(context.l10n.importButton),
            ),
          ],
        ),
      ],
    );
  }
}
