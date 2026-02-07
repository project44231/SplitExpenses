# Poker Tracker - Documentation

Flutter app for tracking poker home games with buy-ins, settlements, and statistics.

## Quick Links

- **[Status](STATUS.md)** - Current progress & next steps
- **[Setup](SETUP.md)** - Firebase configuration (when ready)
- **[Features](FEATURES.md)** - All planned features

## Quick Start

```bash
# Install & run
flutter pub get
flutter run

# Test the COMPLETE MVP flow
1. Splash → Auth screen
2. Click "Continue as Guest"
3. Click "New Game" button
4. Add 3-4 players (search or create new)
5. Select currency & start game
6. Add buy-ins with quick buttons
7. Add rebuys for some players
8. Watch live timer & total pot
9. Click "End Game"
10. Enter cash-out amounts for each player
11. View optimized settlements (who owes whom)
12. Share results via text/messaging!
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
- ✅ New Game screen (player selection, currency)
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
**MVP Progress**: 45%  

**Next**: Build New Game screen (3-4 hrs)

## Need Help?

- Current status → [STATUS.md](STATUS.md)
- Firebase setup → [SETUP.md](SETUP.md)
- Feature list → [FEATURES.md](FEATURES.md)

---

**Last Updated**: Feb 6, 2026  
**Version**: 1.0.0  
**Status**: Ready for feature development 🚀
