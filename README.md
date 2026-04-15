# MogMap

**Built for Spring 2026 Claude Builder Club — ClaudeHacks**

MogMap is a collaborative campus exploration game for UW-Madison. Walk to real locations, farm aura, and generate AI-powered team quests where every player gets a unique puzzle piece. The more you move, the more you mog.

---

## What It Is

MogMap turns campus into a live game map. Hotspots — real UW-Madison locations — each have a vibe, a radius, and players waiting. When you physically arrive at a hotspot, you can:

- **Farm aura** — collect passive aura just for showing up (15 on first visit, 3 on repeat)
- **Generate a squad quest** — Claude invents a collaborative multi-part challenge where each player gets a secret piece (a riddle, an answer key, a location clue, a performance task). Pieces interlock; you need the whole team to finish.
- **Mark complete** — your aura reward lands on your profile and your title climbs

Quests are time-limited: 15 min for easy, 30 for medium, 45 for hard. A live countdown builds urgency. Other participants are seeded fake players for the MVP — they show as "nearby" so you experience the full squad feel solo.

---

## Tech Stack

| Layer | Tech |
|---|---|
| iOS App | Swift 5, SwiftUI, MapKit, CoreLocation |
| Architecture | MVVM, `@MainActor ObservableObject`, environment objects |
| Persistence | `UserDefaults` (player profile, aura, streaks) |
| Networking | `URLSession` async/await |
| Backend | TypeScript, Express, Node.js |
| AI | Anthropic Claude API (`claude-sonnet-4-5`) via backend proxy |
| Map | MapKit `Map(position:)` with custom annotations |

---

## Features

- **15 real UW-Madison hotspots** — Memorial Union Terrace, Camp Randall, Bascom Hill, State Street, Library Mall, and more. Each has a radius (75–150m), a vibe, an emoji, and a fixed "players waiting" count.
- **Proximity gating** — Farm Aura and Generate Quest are both disabled unless you're physically within the hotspot's radius
- **AI-generated collaborative quests** — Claude writes a unique puzzle for your squad: each player gets a secret role and clue. One holds the riddle, another the answer, another the location hint.
- **Quest timer** — countdown from quest start. Easy = 15 min, medium = 30 min, hard = 45 min. Quest expires if time runs out.
- **Fake squad** — 2–3 randomly selected brainrot-named fake players appear as nearby participants per hotspot, each assigned their own quest piece by Claude
- **Players waiting** — each hotspot shows 0–4 players waiting (Four Lakes always has 3/4), displayed as filled/empty person icons above the Generate Quest button
- **Aura system** — accumulates across quests and farming. Titles: NPC → Side Character → Main Character → Sigma → Final Boss
- **Percentile rank** — hardcoded distribution curve places you in Bottom 50% through Top 1%
- **Streak tracking** — daily quest streaks with flame counter
- **Title progression bar** — shows all 5 tiers, highlights current, shows progress toward next
- **Custom user location dot** — blue circle with white border and translucent halo
- **Haptic feedback** — medium impact on aura farm, heavy on quest complete
- **Dark theme** — `#1a1a2e` background, `#7c3aed` purple accent, `#fbbf24` gold for aura and legendary hotspots

---

## Setup

### Prerequisites

- Xcode 16+ with iOS 18 SDK
- Node.js 20+
- An [Anthropic API key](https://console.anthropic.com)

### 1. Backend

```bash
cd backend
cp .env.example .env
# Open .env and paste your ANTHROPIC_API_KEY
npm install
npm run dev
```

Server starts at `http://localhost:3001`. Verify:

```bash
curl http://localhost:3001/health
```

Test quest generation:

```bash
curl -X POST http://localhost:3001/api/quest \
  -H 'Content-Type: application/json' \
  -d '{
    "hotspotName": "Bascom Hill",
    "hotspotVibe": "academic sigma grind",
    "hotspotId": "bascom-hill",
    "playerNames": ["You", "AuraMogger99", "CrashOutCarl"]
  }'
```

### 2. iOS App

1. Open `MogMap.xcodeproj` in Xcode
2. Select the **iPhone 16 simulator** (or any iOS 18 device)
3. Make sure the backend is running on `:3001`
4. Hit **Run**

> The app calls `http://localhost:3001` — this works in the simulator without extra config. On a physical device, update the URL in `ClaudeAPIClient.swift` to your machine's local IP.

---

## Project Structure

```
claude-hacks-2026/
├── MogMap.xcodeproj/
├── MogMap/
│   ├── MogMapApp.swift              # @main entry, environment wiring
│   ├── Models/
│   │   ├── Hotspot.swift            # Location model (coords, vibe, emoji, playersWaiting)
│   │   ├── GeneratedQuest.swift     # Quest + QuestPiece (one piece per player)
│   │   ├── PlayerProfile.swift      # Aura, streaks, title, progress
│   │   └── FakePlayer.swift         # Hardcoded brainrot player roster
│   ├── Services/
│   │   ├── LocationManager.swift    # @MainActor CLLocationManager wrapper
│   │   ├── HotspotService.swift     # 15 hotspots + proximity helpers
│   │   ├── ClaudeAPIClient.swift    # POST /api/quest + local fallback
│   │   └── AuraScoringService.swift # Farming points, title tiers, percentile
│   ├── ViewModels/
│   │   ├── MapViewModel.swift       # Hotspot selection, quest gen, timer, farming
│   │   └── ProfileViewModel.swift   # UserDefaults persistence, daily farm reset
│   └── Views/
│       ├── MainTabView.swift         # Tab container (Map / Profile)
│       ├── MapScreenView.swift       # Full-screen MapKit map + overlays
│       ├── HotspotMarker.swift       # Custom annotation (pulsing for rare spots)
│       ├── HotspotDetailSheet.swift  # Sheet: header, waiting players, farm, quest
│       ├── QuestCardView.swift       # Collaborative quest card + countdown timer
│       └── ProfileView.swift         # Aura counter, title, streak, progression bar
└── backend/
    ├── src/index.ts     # Express server + Claude API proxy
    ├── package.json
    ├── tsconfig.json
    └── .env.example
```

---

## How Claude Is Used

The backend sends hotspot context and all player names to `claude-sonnet-4-5` with a brainrot-flavored system prompt. Claude decides the difficulty, writes a 2–3 sentence team challenge description, and generates one unique `QuestPiece` per player — each with a role title and a secret clue. The pieces are designed to require coordination: one player holds the riddle, another the answer, another scouts the location, another leads the finale.

If the backend is unreachable, the app falls back to a locally generated quest so the experience never fully breaks.

---

## Aura Titles

| Title | Aura Required | Percentile |
|---|---|---|
| NPC | 0 | Bottom 50% |
| Side Character | 100 | Top 40% |
| Main Character | 500 | Top 15% |
| Sigma | 2,000 | Top 5% |
| Final Boss | 10,000 | Top 1% |
