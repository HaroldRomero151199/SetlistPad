class PlaylistSyncResult {
  final int addedCount;
  final int removedCount;
  final int totalCount;

  const PlaylistSyncResult({
    required this.addedCount,
    required this.removedCount,
    required this.totalCount,
  });

  bool get hasChanges => addedCount > 0 || removedCount > 0;
}

