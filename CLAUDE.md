# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app (choose a target platform)
flutter run

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Analyze code
flutter analyze

# Build for release (e.g. Android)
flutter build apk
```

All commands should be run from inside the `catch_game/` directory.

## Architecture

This is a Flutter catch game targeting Android, iOS, web, Windows, macOS, and Linux. All game logic lives in [catch_game/lib/lib/main.dart](catch_game/lib/lib/main.dart) — note the unusual nested `lib/lib/` directory structure. The file [catch_game/lib/lib/app.dart](catch_game/lib/lib/app.dart) exists but is empty/unused.

**Key classes:**
- `CatchGame` — root `StatelessWidget`, sets up `MaterialApp`
- `GameScreen` / `_GameScreenState` — the entire game: state, game loop, and rendering
- `Block` — data class holding `x`/`y` position of a falling block

**Game loop:** A `Timer.periodic` at 50ms drives all movement. Each tick moves blocks down 5px, calls `checkCollisions()`, removes off-screen blocks, and randomly spawns new ones (5% chance per tick).

**Collision & health logic** (`checkCollisions`): catching a block adds 10 points; every 5 missed blocks costs 1 health (out of 3). Health reaching 0 ends the game.

**Input:** Arrow keys on desktop via `Focus`/`onKey` (uses deprecated Flutter API, suppressed with `// ignore: deprecated_member_use`). Touch via `GestureDetector` — swipe (`onPanUpdate`) for fine movement (±2px), tap left/right half (`onTapDown`) for coarse movement (±8px). Arrow keys move ±20px.

**Tests:** [catch_game/test/widget_test.dart](catch_game/test/widget_test.dart) uses a local stub `MyApp` widget (not the real game widget) to verify initial UI state, because the real `GameScreen` starts a `Timer` that conflicts with the test environment.

## Use of Coding Folder
-This is a project testing folder and can have several projects with different languages

## Testing
-When any command is given, check the solution several times.
-With that, test the solution at least 3 times or more.