import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/songs_notifier.dart';

class ImportSongDialog extends ConsumerStatefulWidget {
  const ImportSongDialog({super.key});

  @override
  ConsumerState<ImportSongDialog> createState() => _ImportSongDialogState();
}

class _ImportSongDialogState extends ConsumerState<ImportSongDialog> {
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _handleImport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final song = await ref
          .read(songsNotifierProvider.notifier)
          .importSongFromYoutubeUrl(_urlController.text.trim());

      if (mounted) {
        Navigator.of(context).pop(song);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.songImportedSuccess(song.title, song.artist),
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error importing song from YouTube: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (e is FormatException) {
            _errorMessage = context.l10n.errorInvalidYoutubeUrlFormat;
          } else {
            _errorMessage = context.l10n.errorImportingSong;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.video_library, color: context.colorScheme.error),
          const SizedBox(width: 8),
          Text(context.l10n.importFromYoutube),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.importYoutubeDescription,
              style: TextStyle(
                fontSize: 13,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: context.l10n.youtubeUrl,
                hintText: context.l10n.youtubeUrlHint,
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
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: context.colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
            if (_isLoading) ...[
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.fetchingMetadata,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleImport,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.primary,
            foregroundColor: context.colorScheme.onPrimary,
          ),
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.colorScheme.onPrimary,
                  ),
                )
              : Text(context.l10n.importButton),
        ),
      ],
    );
  }
}
