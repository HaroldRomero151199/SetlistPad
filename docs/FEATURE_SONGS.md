# Feature: Songs (`lib/features/songs`)

The **Songs** feature manages the local song catalog, monospace chord/lyrics viewer, inline lyrics editor, online lyrics retrieval integration, and interlinear bilingual translation.

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
│       ├── song_model.g.dart               # Generated Hive serializer
│       └── bilingual_line.dart             # Model representing an aligned pair of original and translated verse
├── presentation/
│   ├── providers/
│   │   ├── songs_notifier.dart             # SongsNotifier managing batch imports, real-time search, and lyrics updates
│   │   ├── bilingual_lyrics_state.dart     # State definition for bilingual translation mode and export
│   │   └── bilingual_lyrics_notifier.dart  # Manages bilingual mode, language selection, translation, and export
│   ├── screens/
│   │   ├── songs_screen.dart               # Main song catalog screen with search bar and song tiles
│   │   └── song_detail_screen.dart         # Song detail screen orchestrating view, edit, search, and bilingual modes
│   ├── views/                              # Composed state/sub-screen views
│   │   ├── song_empty_lyrics_view.dart     # Empty state prompt with one-tap online lyrics search
│   │   ├── song_lyrics_view.dart           # Performance reading view with monospace chords and lyrics
│   │   ├── song_lyrics_edit_view.dart      # Full-featured multiline lyrics and chord editor view
│   │   └── song_bilingual_lyrics_view.dart # Interlinear bilingual lyrics view (original line with translation directly below)
│   ├── widgets/                            # Atomic components and dialogs
│   │   ├── import_song_dialog.dart         # Dialog for importing single songs via YouTube URLs
│   │   ├── song_font_size_toolbar.dart     # Floating/header toolbar controlling chord sheet font scale
│   │   ├── bilingual_line_tile.dart        # Atomic tile displaying a single original verse and its translation below
│   │   └── bilingual_language_selector.dart# Popup selector for target languages (ES, EN, PT, FR, IT, DE)
│   └── utils/
│       └── bilingual_lyrics_parser.dart    # Pure utility for splitting, line alignment, and alternating .txt export formatting
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
     - Bilingual translation mode: renders `SongBilingualLyricsView` displaying the original line on top and the translated verse directly below, integrated with `BilingualLanguageSelector` and `SongFontSizeToolbar`.
3. **Interlinear Translation & Caching**:
   - `TranslationService` resolves the source language heuristically via `LanguageDetector` (analyzing diacritics and stopword frequencies for valid ISO 639-1 codes) before querying external translation endpoints (MyMemory API).
   - Fully resolved translations are cached in Hive (`translations_cache_box`) using a composite key of `songId`, a content hash of the lyrics, and the target language (`${songId}_${lyricsHash}_$targetLang`). This guarantees automatic cache invalidation whenever lyrics are edited or re-downloaded, and prevents partial failures from being permanently cached.
   - `BilingualLyricsParser` preserves stanza breaks, line breaks, and alignment without desynchronizing verse order.
4. **Bilingual Text Export**:
   - `LyricsExportService` generates clean alternating `.txt` files in local storage with sanitized filenames for easy reading and sharing.
