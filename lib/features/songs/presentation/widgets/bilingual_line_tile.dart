import 'package:flutter/material.dart';
import '../../domain/models/bilingual_line.dart';

/// Reusable atomic tile displaying an original lyrics verse and its translation directly below
class BilingualLineTile extends StatelessWidget {
  final BilingualLine line;
  final double fontSize;

  const BilingualLineTile({
    super.key,
    required this.line,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    if (line.isBlank) {
      return SizedBox(height: fontSize * 0.85);
    }

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SelectableText(
            line.original,
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
              height: 1.3,
            ),
          ),
          if (line.hasTranslation)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: SelectableText(
                line.translation!,
                style: TextStyle(
                  fontSize: fontSize * 0.88,
                  fontFamily: 'monospace',
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.primary,
                  height: 1.3,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

