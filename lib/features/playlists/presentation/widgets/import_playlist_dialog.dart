import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/services/models/youtube_playlist_metadata.dart';
import '../../../songs/presentation/providers/songs_notifier.dart';
import '../providers/playlists_notifier.dart';
import '../utils/playlist_name_helper.dart';
import '../views/import_playlist_preview_view.dart';
import '../views/import_playlist_progress_view.dart';
import '../views/import_playlist_url_view.dart';

/// Modal dialog coordinating the import of YouTube playlists into SetlistPad.
class ImportPlaylistDialog extends ConsumerStatefulWidget {
  final YouTubePlaylistMetadata? initialMetadata;
  final String? initialUrl;

  const ImportPlaylistDialog({
    super.key,
    this.initialMetadata,
    this.initialUrl,
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

  String _getUniqueName(String baseName) {
    final existing = ref.read(playlistsNotifierProvider).value ?? [];
    return PlaylistNameHelper.getUniquePlaylistName(baseName, existing);
  }

  void _applyMetadata(YouTubePlaylistMetadata meta) {
    setState(() {
      _metadata = meta;
      _playlistNameController.text = _getUniqueName(meta.title);
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
    setState(() {
      if (_metadata == null) return;
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

  void _toggleItem(String videoId) {
    setState(() {
      if (_selectedVideoIds.contains(videoId)) {
        _selectedVideoIds.remove(videoId);
      } else {
        _selectedVideoIds.add(videoId);
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
      final messenger = ScaffoldMessenger.of(context);
      final l10n = context.l10n;
      final navigator = Navigator.of(context);
      final playlistsNotifier = ref.read(playlistsNotifierProvider.notifier);
      final songsNotifier = ref.read(songsNotifierProvider.notifier);

      String? targetPlaylistId;

      if (_createPlaylist) {
        final rawName = _playlistNameController.text.trim().isNotEmpty
            ? _playlistNameController.text.trim()
            : _metadata!.title;
        final playlistName = _getUniqueName(rawName);

        final newPlaylist = await playlistsNotifier.createPlaylist(
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

      final imported = await songsNotifier.importSongsBatch(
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

      if (!mounted) return;

      navigator.pop(imported);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.playlistImportSuccess(imported.length),
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
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
    return PopScope(
      canPop: !_isImporting,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 540,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _isImporting
                ? ImportPlaylistProgressView(
                    current: _importCurrent,
                    total: _importTotal,
                    onHideDialog: () => Navigator.of(context).pop(),
                  )
                : _metadata == null
                    ? ImportPlaylistUrlView(
                        urlController: _urlController,
                        formKey: _formKey,
                        isLoading: _isLoading,
                        errorMessage: _errorMessage,
                        onCancel: () => Navigator.of(context).pop(),
                        onSubmit: () {
                          if (_formKey.currentState!.validate()) {
                            _fetchPlaylist();
                          }
                        },
                      )
                    : ImportPlaylistPreviewView(
                        metadata: _metadata!,
                        selectedVideoIds: _selectedVideoIds,
                        playlistNameController: _playlistNameController,
                        createPlaylist: _createPlaylist,
                        onCreatePlaylistChanged: (val) {
                          setState(() {
                            _createPlaylist = val ?? true;
                          });
                        },
                        onToggleSelectAll: _toggleSelectAll,
                        onToggleItem: _toggleItem,
                        errorMessage: _errorMessage,
                        onCancel: () => Navigator.of(context).pop(),
                        onImport: _handleImport,
                      ),
          ),
        ),
      ),
    );
  }
}
