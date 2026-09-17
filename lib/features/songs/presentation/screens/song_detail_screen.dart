import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../songs.dart';

class SongDetailScreen extends ConsumerStatefulWidget {
  final Song song;

  const SongDetailScreen({super.key, required this.song});

  @override
  ConsumerState<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends ConsumerState<SongDetailScreen> {
  late TextEditingController _lyricsController;
  bool _isEditing = false;
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
          // Font size controls bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                const Icon(Icons.format_size, size: 20),
                const SizedBox(width: 8),
                Text(context.l10n.textSize, style: const TextStyle(fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: _fontSize,
                    min: 12.0,
                    max: 28.0,
                    divisions: 8,
                    label: '${_fontSize.round()}px',
                    onChanged: (val) {
                      setState(() {
                        _fontSize = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Lyrics Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isEditing
                  ? TextField(
                      controller: _lyricsController,
                      maxLines: null,
                      expands: true,
                      style: TextStyle(
                        fontSize: _fontSize,
                        fontFamily: 'monospace',
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        hintText: context.l10n.lyricsHint,
                        border: const OutlineInputBorder(),
                      ),
                    )
                  : SingleChildScrollView(
                      child: SelectableText(
                        currentSong.lyrics.isEmpty
                            ? context.l10n.noLyricsAvailable
                            : currentSong.lyrics,
                        style: TextStyle(
                          fontSize: _fontSize,
                          fontFamily: 'monospace',
                          height: 1.5,
                          color: currentSong.lyrics.isEmpty ? context.colorScheme.onSurfaceVariant : null,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
