# Poker Tracker - Documentation

Flutter app for tracking poker home games with buy-ins, settlements, and statistics.

## Quick Links

- **[Status](STATUS.md)** - Current progress & next steps
- **[Setup](SETUP.md)** - Firebase configuration (when ready)
- **[Features](FEATURES.md)** - All planned features
- **[Color Theme](COLOR_THEME.md)** - 🎨 Modern blue color scheme & design guidelines

## Quick Start

```bash
# Install & run
flutter pub get
flutter run

# Test the STREAMLINED flow (NEW!)
1. Splash → Auth screen
2. Click "Continue as Guest"
3. **Lands directly on Active Game!**
4. Click "Add Player" → Add 3-4 players
5. **Click "+" next to any player** → Enter amount → Done! ⚡
6. Add rebuys (click "+" again or use bottom "Add Buy-In" button)
7. Watch live timer & total pot
8. Click "End Game" (top right)
9. Enter cash-out amounts for each player
10. View optimized settlements (who owes whom)
11. Share results via text/messaging!

**Super Fast:** No extra screens! 2-click buy-ins with "+" buttons!
```

## Tech Stack

- **Flutter** 3.27.0
- **State**: Riverpod
- **Storage**: Hive (local), Firebase (cloud)
- **Models**: Freezed
- **Nav**: go_router
- **Algorithm**: Debt simplification (minimizes transactions)

## Features

### Working Now ✅ (MVP v0.1)
- ✅ Guest mode with persistence
- ✅ Streamlined UX (Auth → Active Game directly)
- ✅ Quick buy-ins: "+" button on each player (2-click workflow!)
- ✅ Active Game tracking (live timer, buy-ins, rebuys)
- ✅ Settlement screen (cash-outs, profit/loss, optimized transfers)
- ✅ Share game results
- ✅ Local data storage
- ✅ Professional UI
- ✅ Zero linter errors

### Next Up 🚧
- Game history & statistics
- Firebase integration (optional)
- Player leaderboards

## Project Structure

```
lib/
├── core/           # Config, theme, utils
├── features/       # Auth, game, history, profile
├── models/         # Data models
├── services/       # Business logic
└── shared/         # Shared widgets
```

## Development

```bash
# Hot reload
Press 'r' in terminal

# Hot restart
Press 'R' in terminal

# Analyze
flutter analyze

# Test
flutter test
```

## Key Files

**Services**:
- `lib/services/local_storage_service.dart` - Hive storage
- `lib/services/settlement_service.dart` - Debt algorithm

**Auth**:
- `lib/features/auth/services/auth_service.dart`
- `lib/features/auth/providers/auth_provider.dart`

**Models** (all in `lib/models/`):
- `game.dart`, `player.dart`, `buy_in.dart`, `cash_out.dart`
- `settlement.dart`, `expense.dart`, `game_group.dart`

## Current Status

**Phase 1**: ✅ Foundation complete  
**Guest Mode**: ✅ Working  
**Streamlined UX**: ✅ Complete  
**Settlement**: ✅ Complete  
**MVP Progress**: 88%  

**Next**: Game history & statistics (3-4 hrs)

## Need Help?

- Current status → [STATUS.md](STATUS.md)
- Firebase setup → [SETUP.md](SETUP.md)
- Feature list → [FEATURES.md](FEATURES.md)

---

**Last Updated**: Feb 7, 2026  
**Version**: 0.1.0  
**Status**: 88% to MVP - Quick Buy-In Ready! ⚡
