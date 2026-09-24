# Feature: Songs (`lib/features/songs`)

The **Songs** feature manages the local song catalog, monospace chord/lyrics viewer, inline lyrics editor, and online lyrics retrieval integration.

---

## 1. Directory Structure

```text
lib/features/songs/
├── data/
│   └── repositories/
│       └── song_repository.dart            # SongRepository interface and HiveSongRepository implementation
├── domain/
│   └── models/
│       ├── song_model.dart                 # Immutable Song entity with Hive TypeAdapter (typeId: 0)
│       └── song_model.g.dart               # Generated Hive serializer
├── presentation/
│   ├── providers/
│   │   └── songs_notifier.dart             # SongsNotifier managing batch imports, real-time search, and lyrics updates
│   ├── screens/
│   │   ├── songs_screen.dart               # Main song catalog screen with search bar and song tiles
│   │   └── song_detail_screen.dart         # Song detail screen orchestrating view, edit, and search modes
│   ├── views/                              # Composed state/sub-screen views
│   │   ├── song_empty_lyrics_view.dart     # Empty state prompt with one-tap online lyrics search
│   │   ├── song_lyrics_view.dart           # Performance reading view with monospace chords and lyrics
│   │   └── song_lyrics_edit_view.dart      # Full-featured multiline lyrics and chord editor view
│   └── widgets/                            # Atomic components and dialogs
│       ├── import_song_dialog.dart         # Dialog for importing single songs via YouTube URLs
│       └── song_font_size_toolbar.dart     # Floating/header toolbar controlling chord sheet font scale
└── songs.dart                              # Public barrel export for the songs feature
```

---

## 2. Workflows & Responsibilities

1. **Progressive Batch Import**:
   - `SongsNotifier.importSongsBatch`: Iteratively processes imported playlist items, queries `LyricsService` with graceful fallback, and commits each item to Hive immediately. It calls `await loadSongs()` on each saved track so the UI updates progressively.
2. **Song Detail Modes**:
   - `SongDetailScreen` cleanly delegates UI rendering based on state:
     - Empty lyrics: renders `SongEmptyLyricsView` with automated search.
     - Edit mode: renders `SongLyricsEditView`.
     - Read/Performance mode: renders `SongLyricsView` coupled with `SongFontSizeToolbar`.
