# Agent Guidelines & Architecture Map for SetlistPad

This document serves as the **primary entry point** for any AI Agent or developer working on the **SetlistPad** codebase. It outlines core architectural rules and provides a comprehensive navigation map across features.

---

## 🗺️ Documentation & Feature Map

For in-depth implementation details and file organization, refer to the dedicated feature specifications:

1. 📂 **[Playlists Feature](docs/FEATURE_PLAYLISTS.md)**:
   - Playlist management, YouTube playlist batch import, and UI separation into `screens/`, `views/`, `widgets/`, and `utils/`.
2. 📂 **[Songs Feature](docs/FEATURE_SONGS.md)**:
   - Song catalog, real-time search, monospace chord/lyrics viewer, font size toolbar, and lyrics editor.
3. 📂 **[Core Architecture](docs/CORE_ARCHITECTURE.md)**:
   - Modular HTTP clients (`lrclib`, `youtube`, `lyrics_ovh`), domain services, regex title sanitization, and Levenshtein/token fuzzy matching algorithms.
4. 📂 **[Lyrics Engine & Playlist Import](docs/LYRICS_ENGINE_AND_PLAYLIST_IMPORT.md)**:
   - Technical specifications and algorithmic breakdown of the playlist scraper, track sanitizer, and lyrics search engine.

---

## 🏛️ Mandatory Architectural Rules

### 1. Vertical Slicing & Single Responsibility Principle (SRP)
- **One class per file**: Never combine DTOs, requests, responses, or multiple widgets into a single file.
- **Strict Presentation Layer Separation**:
  - `screens/`: Full-page destinations with navigation routes (`Scaffold`, `AppBar`).
  - `views/`: Composed step/state views representing major sections of a screen or dialog.
  - `widgets/`: Reusable atomic UI components and orchestrator dialogs.
  - `utils/`: Pure UI presentation helpers and formatting algorithms without widget dependencies.
- **Modular HTTP Clients in `core/clients/`**:
  - Every external service client (`lrclib`, `youtube`, `lyrics_ovh`) resides in its own domain folder containing its private `models/`, client class, and barrel export.

### 2. Platform File Stability
- **Never modify or commit** generated platform files in `linux/flutter/`, `macos/Flutter/`, or `windows/flutter/ephemeral/`.
- All changes must remain strictly scoped to `lib/`, `test/`, and `docs/`.

### 3. Quality Assurance Standards
- Before completing any task:
  - `dart analyze`: Must report **0 issues found**.
  - `flutter test`: All tests must pass with a **100% pass rate**.
