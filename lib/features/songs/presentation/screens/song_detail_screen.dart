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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentBilingual = ref.read(bilingualLyricsNotifierProvider);
        if (currentBilingual.songId != widget.song.id) {
          ref.read(bilingualLyricsNotifierProvider.notifier).reset();
        }
      }
    });
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
    final bilingualState = ref.watch(bilingualLyricsNotifierProvider);
    final isBilingualForCurrentSong =
        bilingualState.songId == currentSong.id &&
            bilingualState.isBilingualMode;

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
          if (!_isEditing && currentSong.lyrics.isNotEmpty) ...[
            IconButton(
              icon: Icon(
                isBilingualForCurrentSong
                    ? Icons.translate
                    : Icons.translate_outlined,
              ),
              tooltip: isBilingualForCurrentSong
                  ? context.l10n.originalLyrics
                  : context.l10n.bilingualLyrics,
              onPressed: () {
                ref
                    .read(bilingualLyricsNotifierProvider.notifier)
                    .toggleBilingualMode(currentSong);
              },
            ),
            if (isBilingualForCurrentSong)
              IconButton(
                icon: bilingualState.isExporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.file_download_outlined),
                tooltip: context.l10n.exportBilingualTxt,
                onPressed: bilingualState.isExporting
                    ? null
                    : () async {
                        final file = await ref
                            .read(bilingualLyricsNotifierProvider.notifier)
                            .exportToTextFile(currentSong);
                        if (!context.mounted) return;
                        if (file != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.l10n.exportSuccess(file.path),
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.l10n.exportFailed),
                            ),
                          );
                        }
                      },
              ),
          ],
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
          if (!_isEditing &&
              currentSong.lyrics.isNotEmpty &&
              isBilingualForCurrentSong)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.targetLanguage,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  BilingualLanguageSelector(
                    selectedLanguage: bilingualState.targetLanguage,
                    onLanguageSelected: (newLang) {
                      ref
                          .read(bilingualLyricsNotifierProvider.notifier)
                          .setTargetLanguage(currentSong, newLang);
                    },
                  ),
                ],
              ),
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
                      : isBilingualForCurrentSong
                          ? SongBilingualLyricsView(
                              lines: bilingualState.lines,
                              fontSize: _fontSize,
                              isLoading: bilingualState.isLoading,
                              errorMessage: bilingualState.errorMessage,
                              onRetry: () => ref
                                  .read(bilingualLyricsNotifierProvider.notifier)
                                  .translate(currentSong, forceRefresh: true),
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
