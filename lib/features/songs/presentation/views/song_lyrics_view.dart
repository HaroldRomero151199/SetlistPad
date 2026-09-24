import 'package:flutter/material.dart';

/// Read-only selectable viewer displaying formatted lyrics with adjustable font size
class SongLyricsViewer extends StatelessWidget {
  final String lyrics;
  final double fontSize;

  const SongLyricsViewer({
    super.key,
    required this.lyrics,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SelectableText(
        lyrics,
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: 'monospace',
          height: 1.5,
        ),
      ),
    );
  }
}
