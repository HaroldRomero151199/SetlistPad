# Core Architecture (`lib/core`)

The **Core** module provides shared infrastructure, domain-specific network clients, application configurations, and global utilities across SetlistPad.

---

## 1. Directory Structure

```text
lib/core/
├── clients/                                # Domain-driven HTTP clients (Network Vertical Slicing)
│   ├── lrclib/                             # LRCLIB API client (synchronized and plain text lyrics)
│   │   ├── models/                         # DTOs: GetLyricsRequest, SearchLyricsRequest, LrclibResponse
│   │   ├── lrclib_client.dart
│   │   └── lrclib.dart
│   ├── lyrics_ovh/                         # Lyrics.ovh API client (fallback for international & classic tracks)
│   │   ├── models/                         # DTO: LyricsOvhResponse
│   │   ├── lyrics_ovh_client.dart
│   │   └── lyrics_ovh.dart
│   ├── youtube/                            # YouTube API client (oEmbed extraction and playlist scraping)
│   │   ├── models/                         # DTOs: oEmbed and playlist track items/responses
│   │   ├── youtube_client.dart
│   │   └── youtube.dart
│   ├── translation/                        # Translation API client (MyMemory API integration)
│   │   ├── models/                         # DTOs: TranslationRequest, TranslationResponse
│   │   ├── translation_client.dart
│   │   └── translation.dart
│   └── clients.dart                        # Unified barrel export for all HTTP clients
├── config/
│   ├── api_config.dart                     # API endpoint constants and request timeouts
│   ├── hive_config.dart                    # Hive box initialization and adapter registration
│   └── config.dart
├── navigation/
│   └── main_navigation_screen.dart         # Bottom Navigation Shell (Songs / Playlists)
├── providers/
│   └── providers.dart                      # Global Riverpod providers (Hive boxes, client singletons)
├── services/                               # Domain orchestration services and algorithms
│   ├── models/                             # Service-layer DTOs (YouTubePlaylistItem, metadata models)
│   ├── utils/                              # Business algorithmic utilities
│   │   ├── candidate_match_scorer.dart     # Levenshtein distance & token overlap fuzzy matching scorer
│   │   ├── language_detector.dart          # Heuristic stopword & diacritic analyzer for ISO 639-1 language detection
│   │   └── track_title_sanitizer.dart      # Regex pipeline stripping YouTube junk from track titles
│   ├── lyrics_export_service.dart          # Formats and exports alternating bilingual lyrics to .txt files
│   ├── lyrics_service.dart                 # Two-stage lyrics orchestrator (LRCLIB -> Lyrics.ovh fallback)
│   ├── translation_service.dart            # Interlinear lyrics translation, language detection, and Hive caching
│   ├── youtube_service.dart                # URL parser and metadata extractor
│   └── services.dart
└── theme/
    └── app_theme.dart                      # Material 3 Dark theme, typography, and BuildContextThemeX extensions
```
