import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/services/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../songs/presentation/providers/songs_notifier.dart';
import '../../presentation/providers/playlists_notifier.dart';

class ImportPlaylistDialog extends ConsumerStatefulWidget {
  final String? initialUrl;
  final YouTubePlaylistMetadata? initialMetadata;

  const ImportPlaylistDialog({
    super.key,
    this.initialUrl,
    this.initialMetadata,
  });

  @override
  ConsumerState<ImportPlaylistDialog> createState() =>
      _ImportPlaylistDialogState();
}

class _ImportPlaylistDialogState extends ConsumerState<ImportPlaylistDialog> {
  final _urlController = TextEditingController();
  final _playlistNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isImporting = false;
  int _importCurrent = 0;
  int _importTotal = 0;
  String? _errorMessage;

  YouTubePlaylistMetadata? _metadata;
  final Set<String> _selectedVideoIds = {};
  bool _createPlaylist = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialMetadata != null) {
      _applyMetadata(widget.initialMetadata!);
    } else if (widget.initialUrl != null) {
      _urlController.text = widget.initialUrl!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchPlaylist();
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _playlistNameController.dispose();
    super.dispose();
  }

  void _applyMetadata(YouTubePlaylistMetadata meta) {
    setState(() {
      _metadata = meta;
      _playlistNameController.text = meta.title;
      _selectedVideoIds.clear();
      for (final item in meta.items) {
        _selectedVideoIds.add(item.videoId);
      }
      _isLoading = false;
      _errorMessage = null;
    });
  }

  Future<void> _fetchPlaylist() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final youtubeService = ref.read(youtubeServiceProvider);
      final metadata = await youtubeService.fetchPlaylistMetadata(url);

      if (!mounted) return;

      if (metadata.items.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = context.l10n.errorPlaylistEmpty;
        });
      } else {
        _applyMetadata(metadata);
      }
    } catch (e) {
      debugPrint('Error fetching YouTube playlist: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (e is FormatException) {
          _errorMessage = context.l10n.errorInvalidPlaylistUrl;
        } else {
          _errorMessage = context.l10n.errorFetchingPlaylist;
        }
      });
    }
  }

  void _toggleSelectAll() {
    if (_metadata == null) return;
    setState(() {
      if (_selectedVideoIds.length == _metadata!.items.length) {
        _selectedVideoIds.clear();
      } else {
        _selectedVideoIds.clear();
        for (final item in _metadata!.items) {
          _selectedVideoIds.add(item.videoId);
        }
      }
    });
  }

  Future<void> _handleImport() async {
    if (_metadata == null || _selectedVideoIds.isEmpty) return;

    final selectedItems = _metadata!.items
        .where((item) => _selectedVideoIds.contains(item.videoId))
        .toList();

    setState(() {
      _isImporting = true;
      _importCurrent = 0;
      _importTotal = selectedItems.length;
    });

    try {
      String? targetPlaylistId;

      if (_createPlaylist) {
        final playlistName = _playlistNameController.text.trim().isNotEmpty
            ? _playlistNameController.text.trim()
            : _metadata!.title;

        final newPlaylist = await ref
            .read(playlistsNotifierProvider.notifier)
            .createPlaylist(
              name: playlistName,
              description: _metadata!.author != null
                  ? 'YouTube: ${_metadata!.author}'
                  : '',
              youtubePlaylistUrl: _urlController.text.trim().isNotEmpty
                  ? _urlController.text.trim()
                  : null,
            );
        targetPlaylistId = newPlaylist.id;
      }

      final imported = await ref
          .read(songsNotifierProvider.notifier)
          .importSongsBatch(
            selectedItems,
            targetPlaylistId: targetPlaylistId,
            onProgress: (current, total) {
              if (mounted) {
                setState(() {
                  _importCurrent = current;
                  _importTotal = total;
                });
              }
            },
          );

      if (mounted) {
        Navigator.of(context).pop(imported);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.playlistImportSuccess(imported.length),
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error importing batch songs: $e');
      if (mounted) {
        setState(() {
          _isImporting = false;
          _errorMessage = context.l10n.errorImportingSong;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 540,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _isImporting
              ? _buildImportingProgress(colorScheme)
              : _metadata == null
                  ? _buildUrlInput(colorScheme)
                  : _buildPreview(colorScheme),
        ),
      ),
    );
  }

  Widget _buildUrlInput(ColorScheme colorScheme) {
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
          key: _formKey,
          child: TextFormField(
            controller: _urlController,
            enabled: !_isLoading,
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
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: TextStyle(color: colorScheme.error, fontSize: 12),
          ),
        ],
        if (_isLoading) ...[
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
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              child: Text(context.l10n.cancel),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        _fetchPlaylist();
                      }
                    },
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

  Widget _buildPreview(ColorScheme colorScheme) {
    final meta = _metadata!;
    final allSelected = _selectedVideoIds.length == meta.items.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.playlist_play, color: colorScheme.primary, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.playlistPreviewTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    meta.title,
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
          value: _createPlaylist,
          onChanged: (val) {
            setState(() {
              _createPlaylist = val ?? true;
            });
          },
          title: Text(
            context.l10n.createPlaylistWithSongs,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        if (_createPlaylist) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TextField(
              controller: _playlistNameController,
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
              context.l10n.songsCount(_selectedVideoIds.length),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            TextButton.icon(
              onPressed: _toggleSelectAll,
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
            itemCount: meta.items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = meta.items[index];
              final isSelected = _selectedVideoIds.contains(item.videoId);

              return CheckboxListTile(
                value: isSelected,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedVideoIds.add(item.videoId);
                    } else {
                      _selectedVideoIds.remove(item.videoId);
                    }
                  });
                },
                title: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
            },
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: TextStyle(color: colorScheme.error, fontSize: 12),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.cancel),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _selectedVideoIds.isEmpty ? null : _handleImport,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text(
                context.l10n.importSelectedSongs(_selectedVideoIds.length),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImportingProgress(ColorScheme colorScheme) {
    final progress =
        _importTotal > 0 ? _importCurrent / _importTotal : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Icon(Icons.cloud_download, color: colorScheme.primary, size: 48),
        const SizedBox(height: 16),
        Text(
          context.l10n.importingSongProgress(_importCurrent, _importTotal),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: colorScheme.surfaceContainerHighest,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
