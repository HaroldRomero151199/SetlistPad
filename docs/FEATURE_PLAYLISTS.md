# Feature: Playlists (`lib/features/playlists`)

The **Playlists** feature handles creating, managing, viewing, and batch-importing musical repertoires and song collections.

---

## 1. Directory Structure

```text
lib/features/playlists/
├── data/
│   └── repositories/
│       └── playlist_repository.dart        # PlaylistRepository interface and HivePlaylistRepository implementation
├── domain/
│   └── models/
│       ├── playlist_model.dart             # Immutable Playlist entity with Hive TypeAdapter (typeId: 1)
│       └── playlist_model.g.dart           # Generated Hive serializer
├── presentation/
│   ├── providers/
│   │   └── playlists_notifier.dart         # Riverpod Notifier for reactive playlist state
│   ├── screens/
│   │   ├── playlists_screen.dart           # Primary screen (playlist cards, creation FAB, import action)
│   │   └── playlist_detail_screen.dart     # Detailed playlist view (song ordering, track removal)
│   ├── views/                              # Step/state views composing multi-stage dialogs
│   │   ├── import_playlist_url_view.dart      # Step 1: YouTube playlist URL input and validation
│   │   ├── import_playlist_preview_view.dart  # Step 2: Track preview, checkboxes, and playlist name editor
│   │   └── import_playlist_progress_view.dart # Step 3: Real-time progress bar with "run in background" option
│   ├── widgets/                            # Atomic widgets and orchestrator modals
│   │   ├── import_playlist_dialog.dart        # Modal dialog orchestrator
│   │   └── import_playlist_track_tile.dart    # Individual track list tile with indexed avatar and checkbox
│   └── utils/                              # Presentation-specific helper logic
│       └── playlist_name_helper.dart          # Collision avoidance logic generating unique names (e.g. "(2)")
└── playlists.dart                          # Public barrel export for the playlists feature
```

---

## 2. Workflows & Responsibilities

1. **YouTube Playlist Import**:
   - `ImportPlaylistDialog` orchestrates the multi-step state machine without bloating the widget tree.
   - If no playlist metadata is loaded, it presents `ImportPlaylistUrlView`.
   - Once fetched, it renders `ImportPlaylistPreviewView` allowing track deselection and playlist renaming. Collision prevention is guaranteed by `PlaylistNameHelper`.
   - Upon confirmation, it switches to `ImportPlaylistProgressView`. The dialog is safeguarded against accidental dismissals via `barrierDismissible: false` and `PopScope(canPop: !_isImporting)`. A dedicated button allows the user to dismiss the UI while letting the import finish in the background.
2. **Persistence**:
   - Manages CRUD operations via `HivePlaylistRepository` backed by the `playlistsBox` Hive storage box.
