import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Multiline text editor for modifying and formatting song lyrics
class SongLyricsEditor extends StatelessWidget {
  final TextEditingController controller;
  final double fontSize;

  const SongLyricsEditor({
    super.key,
    required this.controller,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: null,
      expands: true,
      style: TextStyle(
        fontSize: fontSize,
        fontFamily: 'monospace',
        height: 1.4,
      ),
      decoration: InputDecoration(
        hintText: context.l10n.lyricsHint,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
