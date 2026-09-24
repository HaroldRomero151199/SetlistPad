# SetlistPad 🎵

A modern, offline-first Flutter application tailored for live musicians and bands to manage songs, chords, lyrics, and gig setlists seamlessly.

---

## ✨ Features

- **Offline-First Storage**: Fast and reliable local persistence powered by **Hive**.
- **YouTube Playlist & Song Import**:
  - Direct import from YouTube playlist or video URLs.
  - Automated title and artist cleaning stripping redundant video tags (e.g. `[Official Video]`, `(Live @ Festival 2024)`).
  - Collision prevention avoiding duplicate playlist names.
  - Progressive background import displaying added songs in real time.
- **Intelligent Online Lyrics Engine**:
  - Two-stage multi-source lyrics lookup via **LRCLIB** and **Lyrics.ovh**.
  - Advanced fuzzy matching scoring candidates using token overlap and Levenshtein similarity.
- **Stage-Ready Performance Viewer**:
  - Monospace font typography ensuring chord alignment over lyrics.
  - Dynamic font scale controls for stage readability.
  - Full-screen distraction-free layout.
- **Internationalization (i18n)**:
  - English and Spanish localizations with automatic locale detection.

---

## 🏛️ Architecture & Directory Layout

SetlistPad adheres strictly to **Clean Architecture** and **Vertical Slicing**:

```text
lib/
├── core/                   # Shared cross-cutting modules (clients, services, theme, config)
├── features/
│   ├── playlists/          # Playlists domain, repository, screens, views, widgets, and utils
│   └── songs/              # Songs domain, repository, screens, and widgets
└── l10n/                   # ARB localization definitions and generated classes
```

For comprehensive guidelines and architectural specifications, consult:
- 📖 [AGENTS.md](AGENTS.md) — Architectural entry point and developer rules.
- 📖 [Playlists Feature Documentation](docs/FEATURE_PLAYLISTS.md)
- 📖 [Songs Feature Documentation](docs/FEATURE_SONGS.md)
- 📖 [Core Architecture Documentation](docs/CORE_ARCHITECTURE.md)
- 📖 [Lyrics Engine & Scraper Deep Dive](docs/LYRICS_ENGINE_AND_PLAYLIST_IMPORT.md)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.3.0`
- Dart SDK `>=3.3.0`

### Installation
```bash
# Clone the repository
git clone https://github.com/your-username/SetlistPad.git

# Navigate to project directory
cd SetlistPad

# Fetch dependencies
flutter pub get

# Generate localizations and Hive adapters
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Run application
flutter run
```

---

## 🧪 Testing

The test suite covers unit and widget tests across all domain layers:
```bash
flutter test
```
