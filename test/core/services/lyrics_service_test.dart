import 'package:flutter_test/flutter_test.dart';
import 'package:setlist_pad/core/services/lyrics_service.dart';

void main() {
  group('LyricsService Tests', () {
    late LyricsService service;

    setUp(() {
      service = LyricsService();
    });

    test('cleanSyncedLyrics should strip LRC timestamps', () {
      const synced = '[00:12.34]Look at the stars\n[00:15.67]Look how they shine for you';
      final cleaned = service.cleanSyncedLyrics(synced);
      expect(cleaned, 'Look at the stars\nLook how they shine for you');
    });
  });
}
