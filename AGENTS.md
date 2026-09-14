# Agent Guidelines & Development Rules for SetlistPad

This document defines mandatory guidelines, architecture principles, and best practices for AI agents working on the **SetlistPad** codebase.

---

## 1. Package Dependencies Rule
- **Always use the latest stable versions** of all packages in `pubspec.yaml`.
- Never introduce deprecated or outdated major versions when adding dependencies (e.g., use latest Riverpod 3.x, latest Hive, latest http, etc.).
- Run `flutter pub upgrade --major-versions` to verify package compatibility when adding new libraries.

---

## 2. Architecture & Code Structure
SetlistPad follows a **Feature-First + Clean Architecture** modular pattern.

```
lib/
├── core/
│   ├── clients/         # Low-level HTTP/API clients & DTOs (Requests/Responses)
│   │   ├── models/      # Strongly-typed Request and Response models
│   │   └── clients.dart # Barrel file for clients & DTOs
│   ├── config/          # Global constants, API endpoints (ApiConfig), Hive box names (HiveBoxes)
│   │   └── config.dart  # Barrel file for config
│   ├── providers/       # Global Riverpod providers & dependency injection wiring
│   ├── services/        # Business logic services (YouTube, Lyrics)
│   │   └── services.dart# Barrel file for services
│   └── theme/           # App themes, colors, typography
├── features/
│   ├── songs/           # Songs feature (domain/models, data/repositories, presentation)
│   │   └── songs.dart   # Feature barrel file
│   └── playlists/       # Playlists feature (domain/models, data/repositories, presentation)
│       └── playlists.dart # Feature barrel file
└── main.dart
```

### Architectural Layering Guidelines
1. **Clients Layer (`lib/core/clients/`)**: Handles raw HTTP operations, status code checks, and JSON mapping using explicit Request (`toQueryParameters()`) and Response (`fromJson()`) DTO classes.
2. **Services Layer (`lib/core/services/`)**: Consumes Clients to perform domain service logic (parsing YouTube links, cleaning lyrics timestamps, handling fallbacks).
3. **Data/Repository Layer (`lib/features/*/data/repositories/`)**: Abstract repository interfaces with Hive local storage implementations (`HiveSongRepository`, `HivePlaylistRepository`).
4. **State Management**: **Flutter Riverpod** (`flutter_riverpod`). Always inject dependencies using Riverpod `Provider` / `Notifier`.
5. **Barrel Files**: Always export related classes in feature/module barrel files (`clients.dart`, `services.dart`, `songs.dart`, `playlists.dart`) to keep imports clean and maintainable.

---

## 3. Testing & Verification Rules
- Always maintain unit test coverage for services, clients, models, and repositories.
- Before committing any changes, verify that:
  1. `flutter analyze` passes with zero issues/warnings.
  2. `flutter test` executes with 100% passing tests.
