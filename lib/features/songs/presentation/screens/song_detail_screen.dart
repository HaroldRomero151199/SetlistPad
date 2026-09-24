import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../songs.dart';

/// Screen displaying song details, lyrics viewer/editor, and online lyrics retrieval
class SongDetailScreen extends ConsumerStatefulWidget {
  final Song song;

  const SongDetailScreen({super.key, required this.song});

  @override
  ConsumerState<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends ConsumerState<SongDetailScreen> {
  late TextEditingController _lyricsController;
  bool _isEditing = false;
  bool _isSearchingLyrics = false;
  double _fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _lyricsController = TextEditingController(text: widget.song.lyrics);
  }

  @override
  void dispose() {
    _lyricsController.dispose();
    super.dispose();
  }

  Future<void> _saveLyrics() async {
    await ref
        .read(songsNotifierProvider.notifier)
        .updateLyrics(widget.song.id, _lyricsController.text);

    setState(() {
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.lyricsUpdatedSuccess)),
      );
    }
  }

  Future<void> _searchLyricsOnline() async {
    setState(() {
      _isSearchingLyrics = true;
    });

    try {
      final success = await ref
          .read(songsNotifierProvider.notifier)
          .fetchAndSaveLyrics(widget.song.id);

      if (!mounted) return;

      if (success) {
        final currentSongs = ref.read(songsNotifierProvider).value;
        final updatedSong = currentSongs?.firstWhere(
          (s) => s.id == widget.song.id,
          orElse: () => widget.song,
        );
        if (updatedSong != null) {
          _lyricsController.text = updatedSong.lyrics;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.lyricsFoundSuccess)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.noLyricsFoundOnline)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.noLyricsFoundOnline)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearchingLyrics = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(songsNotifierProvider);
    final currentSong = songsAsync.whenData((songs) =>
            songs.firstWhere((s) => s.id == widget.song.id, orElse: () => widget.song)).value ??
        widget.song;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(currentSong.title, style: const TextStyle(fontSize: 18)),
            Text(
              currentSong.artist,
              style: TextStyle(fontSize: 12, color: context.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: _isSearchingLyrics
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_rounded),
              tooltip: context.l10n.searchLyricsOnline,
              onPressed: _isSearchingLyrics ? null : _searchLyricsOnline,
            ),
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            tooltip: _isEditing ? context.l10n.saveLyrics : context.l10n.editLyrics,
            onPressed: () {
              if (_isEditing) {
                _saveLyrics();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SongFontSizeToolbar(
            fontSize: _fontSize,
            onFontSizeChanged: (val) {
              setState(() {
                _fontSize = val;
              });
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isEditing
                  ? SongLyricsEditor(
                      controller: _lyricsController,
                      fontSize: _fontSize,
                    )
                  : currentSong.lyrics.isEmpty
                      ? SongEmptyLyricsView(
                          isSearchingLyrics: _isSearchingLyrics,
                          onSearchOnline: _searchLyricsOnline,
                        )
                      : SongLyricsViewer(
                          lyrics: currentSong.lyrics,
                          fontSize: _fontSize,
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
