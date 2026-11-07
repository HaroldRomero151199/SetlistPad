import '../../../../core/services/services.dart';
import '../../../songs/songs.dart';
import '../models/playlist_model.dart';

/// Encapsulates all validation rules and prerequisite checks required
/// before and during YouTube playlist synchronization.
class PlaylistSyncValidator {
  const PlaylistSyncValidator();

  /// Validates that the playlist exists and contains a valid YouTube playlist URL.
  ///
  /// Returns the trimmed YouTube URL if valid, or throws:
  /// - [Exception] if [playlist] is null.
  /// - [FormatException] if [playlist.youtubePlaylistUrl] is null or empty.
  String validatePlaylist(Playlist? playlist) {
    if (playlist == null) {
      throw Exception('Playlist not found');
    }

    final url = playlist.youtubePlaylistUrl;
    if (url == null || url.trim().isEmpty) {
      throw const FormatException('Playlist has no YouTube playlist URL');
    }

    return url.trim();
  }

  /// Validates that required external services are available.
  ///
  /// Throws [StateError] if either service is null.
  void validateRequiredServices({
    required YouTubeService? youtubeService,
    required SongRepository? songRepository,
  }) {
    if (youtubeService == null || songRepository == null) {
      throw StateError('Required services are not available for playlist sync');
    }
  }

  /// Validates that the fetched remote playlist metadata contains playable items
  /// and is a complete snapshot before performing synchronization diffing.
  ///
  /// Throws:
  /// - [Exception] if [metadata.items] is empty.
  /// - [Exception] if [metadata.isComplete] is false (to prevent destructive unlinking on partial reads).
  void validateMetadata(YouTubePlaylistMetadata metadata) {
    if (metadata.items.isEmpty) {
      throw Exception('Playlist is empty or private');
    }
    if (!metadata.isComplete) {
      throw Exception('Remote playlist snapshot is incomplete');
    }
  }
}
