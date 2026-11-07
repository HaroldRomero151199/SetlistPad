# Feature: Playlists (`lib/features/playlists`)

The **Playlists** feature handles creating, managing, viewing, batch-importing, and synchronizing musical repertoires and song collections.

---

## 1. Directory Structure

```text
lib/features/playlists/
├── data/
│   └── repositories/
│       └── playlist_repository.dart        # PlaylistRepository interface and HivePlaylistRepository implementation
├── domain/
│   ├── models/
│   │   ├── playlist_model.dart             # Immutable Playlist entity with Hive TypeAdapter (typeId: 1)
│   │   ├── playlist_model.g.dart           # Generated Hive serializer
│   │   └── playlist_sync_result.dart       # DTO holding diff metrics (addedCount, removedCount, totalCount)
│   └── services/
│       ├── playlist_sync_service.dart      # Domain orchestrator for YouTube sync diffing & song resolution
│       └── playlist_sync_validator.dart    # Pure validation rules for sync prerequisites & remote responses
├── presentation/
│   ├── providers/
│   │   └── playlists_notifier.dart         # Riverpod Notifier for reactive playlist state & sync
│   ├── screens/
│   │   ├── playlists_screen.dart           # Primary screen (playlist cards, creation FAB, import action)
│   │   └── playlist_detail_screen.dart     # Detailed playlist view (song ordering, track removal, sync action)
│   ├── views/                              # Step/state views composing multi-stage dialogs
│   │   ├── import_playlist_url_view.dart      # Step 1: YouTube playlist URL input and validation
│   │   ├── import_playlist_preview_view.dart  # Step 2: Track preview, checkboxes, and playlist name editor
│   │   └── import_playlist_progress_view.dart # Step 3: Real-time progress bar with "run in background" option
│   ├── widgets/                            # Atomic widgets and orchestrator modals
│   │   ├── import_playlist_dialog.dart        # Modal dialog orchestrator
│   │   └── import_playlist_track_tile.dart    # Individual track list tile with indexed avatar and checkbox
│   └── utils/                              # Presentation-specific helper logic
│       ├── playlist_name_helper.dart          # Collision avoidance logic generating unique names (e.g. "(2)")
│       └── playlist_sync_helper.dart          # Localized feedback message formatter for sync results
└── playlists.dart                          # Public barrel export for the playlists feature
```

---

## 2. Workflows & Responsibilities

1. **YouTube Playlist Import**:
   - `ImportPlaylistDialog` orchestrates the multi-step state machine without bloating the widget tree.
   - If no playlist metadata is loaded, it presents `ImportPlaylistUrlView`.
   - Once fetched, it renders `ImportPlaylistPreviewView` allowing track deselection and playlist renaming. Collision prevention is guaranteed by `PlaylistNameHelper`.
   - Upon confirmation, it switches to `ImportPlaylistProgressView`. The dialog is safeguarded against accidental dismissals via `barrierDismissible: false` and `PopScope(canPop: !_isImporting)`. A dedicated button allows the user to dismiss the UI while letting the import finish in the background.

2. **YouTube Playlist Synchronization & Diffing**:
   - Playlists preserving a valid `youtubePlaylistUrl` display a synchronization action button in the `AppBar` of `PlaylistDetailScreen` beside the delete action.
   - **Diffing Engine (`PlaylistSyncService` orchestrated via `PlaylistsNotifier.syncPlaylist`)**:
     - Validated through `PlaylistSyncValidator` to enforce prerequisite invariants (valid playlist existence, YouTube URL format, service dependency availability, non-empty remote metadata).
     - **Additions (+)**: Songs on YouTube that are missing from the local playlist are checked against the song catalog (`SongRepository`) by video ID / URL or title/artist match. If not present in the catalog, lyrics are fetched via `LyricsService`, the new `Song` is persisted in `SongRepository`, and its ID linked to the playlist.
     - **Removals (-)**: Songs present locally that were removed from the remote YouTube playlist are unlinked from the playlist. They remain preserved in the global song catalog to avoid disturbing favorites or historical repertoires.
     - **Error Handling & Non-corruption**: Failures to contact the remote playlist (private, unavailable, network error) leave the local playlist intact and display an informative error SnackBar.
     - **User Feedback**: Formatted via `PlaylistSyncHelper` (e.g. `+1 añadida, -1 removida`), showing descriptive diff metrics.

3. **Persistence**:
   - Manages CRUD operations via `HivePlaylistRepository` backed by the `playlistsBox` Hive storage box.
