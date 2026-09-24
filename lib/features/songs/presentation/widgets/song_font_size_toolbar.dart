import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Control bar allowing users to adjust lyrics font size with a slider
class SongFontSizeToolbar extends StatelessWidget {
  final double fontSize;
  final ValueChanged<double> onFontSizeChanged;

  const SongFontSizeToolbar({
    super.key,
    required this.fontSize,
    required this.onFontSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          const Icon(Icons.format_size, size: 20),
          const SizedBox(width: 8),
          Text(context.l10n.textSize, style: const TextStyle(fontSize: 12)),
          Expanded(
            child: Slider(
              value: fontSize,
              min: 12.0,
              max: 28.0,
              divisions: 8,
              label: '${fontSize.round()}px',
              onChanged: onFontSizeChanged,
            ),
          ),
        ],
      ),
    );
  }
}
