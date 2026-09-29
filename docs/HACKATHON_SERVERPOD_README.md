# 🎵 SetlistPad — Real-Time Live Performance & Smart Lyrics Engine
> Built for the **"Build Something Real: The Serverpod Hackathon"** (Serverpod 4 + Flutter)

[![Serverpod 4](https://img.shields.io/badge/Serverpod-4.0-blue.svg)](https://serverpod.dev)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B.svg?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2.svg?logo=dart)](https://dart.dev)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791.svg?logo=postgresql)](https://www.postgresql.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 🎯 1. Hackathon Objective & Vision: "Build Something Real"

**SetlistPad** is a full-stack Dart application that bridges live music performance and music-driven language learning into a single, cohesive experience.

### Real Problems Solved:
1. **Live Stage Coordination Chaos:** Bands, worship teams, and acoustic ensembles struggle to synchronize setlists, song keys, and lyrics on stage. Static PDFs and paper sheets fail when setlists change on the fly during rehearsals or live concerts.
2. **Missing YouTube Subtitles & Language Learning:** Millions of songs and backing tracks on YouTube lack synchronized lyrics or translations. Casual listeners and language learners have no unified way to follow along or learn languages through the songs they love.

---

## 🗓️ 2. Hackathon Roadmap (5-Week Plan)

| Phase | Timeline | Primary Objective | Serverpod 4 & Flutter Deliverables |
| :--- | :--- | :--- | :--- |
| **Phase 1** | **Week 1** | **Modeling & Authentication** | Define `.spy.yaml` models (`Song`, `Setlist`, `BandSession`), execute Postgres migrations, integrate `serverpod_auth` (Google, Apple, Email). |
| **Phase 2** | **Week 2** | **Lyrics & Translation Engine** | Serverpod endpoints for multi-source lyrics lookup (LRCLIB, scraping fallback), translation caching in PostgreSQL via Serverpod ORM. |
| **Phase 3** | **Week 3** | **Live Band Sync (WebSockets)** | Serverpod streaming sessions: real-time rooms where the bandleader broadcasts song selection, key transpositions, and scroll position. |
| **Phase 4** | **Week 4** | **Client Integration & Offline Sync** | Connect Flutter app via generated client, Riverpod streaming providers, hybrid Hive local storage + Serverpod Cloud synchronization. |
| **Phase 5** | **Week 5** | **Polish, Stage Testing & Submission** | High-contrast stage UI, dual-column language learning viewer, server deployment (Docker/Serverpod Cloud), demo video submission. |

---

## ✨ 3. Core Features

### 🎸 Real-Time Live Stage Sync (Serverpod WebSockets / Streaming)
- **Live Performance Rooms:** Bandleaders create a live room with a 6-character code or QR code.
- **Leader-Follower State Sync:** When the bandleader selects a song, changes the musical key (transposition), or triggers auto-scroll, all connected devices update in **<50ms** via Serverpod streaming.
- **Teleprompter / Auto-Scroll:** Synchronized hands-free scrolling across tablets and phones.

### 🌐 Smart Lyrics & Translation Engine (Backend AI/API Hub)
- **Automatic Lyric Fetching:** Resolves missing lyrics for YouTube tracks via external APIs and background scraping, stored and cached in PostgreSQL.
- **Dual-Language Learning Mode:** Translates song lyrics line-by-line, providing side-by-side or translated subtitles for language learners.

### 🔐 Frictionless Authentication (`serverpod_auth`)
- One-click sign-in with **Google**, **Apple**, or **Email/Password** using Serverpod 4's official authentication modules.
- Cloud profile synchronization across desktop, tablet, and mobile.

### 📦 Offline-First Reliability (Hive + Serverpod Cloud)
- **Zero Stage Panic:** Setlists and cached chord charts remain fully accessible offline via **Hive** local storage even if the venue's Wi-Fi drops completely.
- Automatic two-way cloud sync once internet connection is restored.

---

## 🏛️ 4. Architecture & Tech Stack

SetlistPad is built end-to-end in **pure Dart**:

```text
┌────────────────────────────────────────────────────────┐
│             Flutter Client (Mobile / Tablet / Web)     │
│    • Riverpod 3.x (State)      • Hive (Offline DB)     │
│    • Monospace Chord Viewer    • YouTube Player Engine │
└───────────────────────────▲────────────────────────────┘
                            │
              WebSockets (Streaming) + HTTP
                            │
┌───────────────────────────▼────────────────────────────┐
│                  Serverpod 4 Backend                   │
│  ┌───────────────────────┐   ┌───────────────────────┐ │
│  │   Auth Module (OAuth) │   │  Live Stage Streams   │ │
│  └───────────────────────┘   └───────────────────────┘ │
│  ┌───────────────────────┐   ┌───────────────────────┐ │
│  │ Lyrics & Trans. Engine│   │ Serverpod ORM / Cache │ │
│  └───────────────────────┘   └───────────────────────┘ │
└───────────────────────────▲────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│            PostgreSQL Database & Docker Engine         │
└────────────────────────────────────────────────────────┘
```

---

## 📁 5. Repository Structure

```text
.
├── setlist_pad_server/       # Serverpod 4 backend (endpoints, models, migrations)
│   ├── lib/
│   │   ├── src/
│   │   │   ├── endpoints/    # Auth, Setlist, Lyrics, and LiveSync endpoints
│   │   │   ├── models/       # .spy.yaml definitions
│   │   │   └── services/     # Lyric scrapers and translation services
│   │   └── server.dart
│   └── config/               # Database and server configs
├── setlist_pad_client/       # Generated client library for Flutter
└── setlist_pad_flutter/      # Cross-platform Flutter application
```

---

## 🚀 6. Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`>= 3.3.0`)
- [Dart SDK](https://dart.dev/get-dart) (`>= 3.3.0`)
- [Serverpod CLI 4.x](https://docs.serverpod.dev):
  ```bash
  dart pub global activate serverpod_cli
  ```
- [Docker Desktop](https://www.docker.com/products/docker-desktop) (for PostgreSQL & Redis)

---

### Running Locally

#### 1. Start the Serverpod Backend
```bash
# Navigate to the server folder
cd setlist_pad_server

# Start PostgreSQL and Redis via Docker
docker compose up -d

# Apply database migrations
dart run bin/main.dart --apply-migrations

# Start Serverpod in development mode
dart run bin/main.dart
```

#### 2. Run the Flutter Client
```bash
# Navigate to the Flutter app folder
cd ../setlist_pad_flutter

# Get dependencies
flutter pub get

# Run the app
flutter run
```

---

## 🎯 7. Hackathon Deliverables & Criteria Checklist

- [x] **Full-Stack Dart:** Flutter frontend + Serverpod 4 backend.
- [x] **Real-Time WebSockets:** Live stage synchronization between band members.
- [x] **Database & ORM:** Songs, setlists, and cached translations persisted in PostgreSQL.
- [x] **Authentication:** Built using official Serverpod Auth providers.
- [x] **Real-World Impact:** Solves stage coordination for musicians and lyric translation for language learners.

---

## 👥 Authors & Team
- **Harold Romero** ([@HaroldRomero151199](https://github.com/HaroldRomero151199))

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
