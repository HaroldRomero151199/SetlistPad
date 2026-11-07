import 'package:flutter_test/flutter_test.dart';
import 'package:setlist_pad/features/playlists/domain/models/playlist_sync_result.dart';

void main() {
  group('PlaylistSyncResult Tests', () {
    test('hasChanges should be true when addedCount > 0 or removedCount > 0', () {
      const result1 = PlaylistSyncResult(
        addedCount: 1,
        removedCount: 0,
        totalCount: 5,
      );
      expect(result1.hasChanges, isTrue);

      const result2 = PlaylistSyncResult(
        addedCount: 0,
        removedCount: 2,
        totalCount: 3,
      );
      expect(result2.hasChanges, isTrue);

      const result3 = PlaylistSyncResult(
        addedCount: 2,
        removedCount: 1,
        totalCount: 4,
      );
      expect(result3.hasChanges, isTrue);
    });

    test('hasChanges should be false when both addedCount and removedCount are 0', () {
      const result = PlaylistSyncResult(
        addedCount: 0,
        removedCount: 0,
        totalCount: 3,
      );
      expect(result.hasChanges, isFalse);
    });
  });
}

