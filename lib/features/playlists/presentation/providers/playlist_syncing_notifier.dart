import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks which playlists are currently undergoing remote synchronization.
class PlaylistSyncingNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void setSyncing(String playlistId, bool isSyncing) {
    if (isSyncing) {
      state = {...state, playlistId};
    } else {
      state = state.where((id) => id != playlistId).toSet();
    }
  }
}

final playlistSyncingProvider =
    NotifierProvider<PlaylistSyncingNotifier, Set<String>>(
  PlaylistSyncingNotifier.new,
);

