import 'package:flutter/material.dart';

/// Atomic widget allowing selection of target language for bilingual translation
class BilingualLanguageSelector extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String> onLanguageSelected;

  static const Map<String, String> supportedLanguages = {
    'es': 'Español (ES)',
    'en': 'English (EN)',
    'pt': 'Português (PT)',
    'fr': 'Français (FR)',
    'it': 'Italiano (IT)',
    'de': 'Deutsch (DE)',
  };

  const BilingualLanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLabel =
        supportedLanguages[selectedLanguage] ?? selectedLanguage.toUpperCase();

    return PopupMenuButton<String>(
      initialValue: selectedLanguage,
      tooltip: 'Target Language',
      onSelected: onLanguageSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withAlpha(100),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.translate_rounded,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              currentLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
      itemBuilder: (context) {
        return supportedLanguages.entries.map((entry) {
          final isSelected = entry.key == selectedLanguage;
          return PopupMenuItem<String>(
            value: entry.key,
            child: Row(
              children: [
                if (isSelected)
                  Icon(Icons.check, size: 16, color: theme.colorScheme.primary)
                else
                  const SizedBox(width: 16),
                const SizedBox(width: 8),
                Text(entry.value),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}

