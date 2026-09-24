import '../../domain/models/playlist_model.dart';

/// Helper to generate unique playlist names avoiding accidental collisions.
class PlaylistNameHelper {
  const PlaylistNameHelper._();

  /// Returns [baseName] or [baseName (N)] ensuring no case-insensitive collisions with [existingPlaylists].
  static String getUniquePlaylistName(
    String baseName,
    List<Playlist> existingPlaylists,
  ) {
    final names =
        existingPlaylists.map((p) => p.name.trim().toLowerCase()).toSet();
    final cleanBase = baseName.trim();
    if (!names.contains(cleanBase.toLowerCase())) {
      return cleanBase;
    }
    int counter = 2;
    while (names.contains('${cleanBase.toLowerCase()} ($counter)')) {
      counter++;
    }
    return '$cleanBase ($counter)';
  }
}
