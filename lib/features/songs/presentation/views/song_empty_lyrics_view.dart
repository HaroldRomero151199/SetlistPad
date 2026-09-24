import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Empty state view presented when a song currently has no lyrics,
/// providing an action to fetch them online
class SongEmptyLyricsView extends StatelessWidget {
  final bool isSearchingLyrics;
  final VoidCallback onSearchOnline;

  const SongEmptyLyricsView({
    super.key,
    required this.isSearchingLyrics,
    required this.onSearchOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_off_outlined,
              size: 48,
              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.noLyricsAvailable,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: isSearchingLyrics ? null : onSearchOnline,
              icon: isSearchingLyrics
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.search_rounded),
              label: Text(
                isSearchingLyrics
                    ? context.l10n.searchingLyrics
                    : context.l10n.searchLyricsOnline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
