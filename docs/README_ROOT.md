# Game buy-in tracker

A Flutter app for tracking poker home game buy-ins, managing settlements, and viewing comprehensive statistics.

## 📚 Documentation

- **[Testing](docs/TESTING.md)** - How to test the app ← START HERE!
- **[Status](docs/STATUS.md)** - Current progress & next steps
- **[Overview](docs/README.md)** - Complete documentation
- **[Setup](docs/SETUP.md)** - Firebase configuration (when ready)
- **[Features](docs/FEATURES.md)** - All planned features

## Quick Start

```bash
# Install dependencies
flutter pub get

# Generate model code
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

## Project Status

✅ **Phase 1: Foundation Complete**
- Project setup & dependencies
- Data models (Freezed)
- Settlement algorithm (fully functional)
- Core UI structure
- Comprehensive documentation

✅ **Guest Mode Complete** (Feb 6, 2026)
- Local storage with Hive
- Authentication system
- Data persistence
- App fully functional for offline use

🚧 **Phase 2: Implementation In Progress** (Next: New Game Screen)
- Game tracking screens
- History & statistics
- Firebase integration

## Tech Stack

- Flutter 3.27.0
- Riverpod (State Management)
- Firebase (Auth, Firestore, Storage, Analytics)
- Freezed (Immutable Models)
- go_router (Navigation)

## Key Features

- 💰 Track buy-ins and rebuys
- 🎯 Optimized settlement algorithm (minimizes transactions)
- 📊 Game history and statistics
- 👥 Multiple game groups
- 💱 Multi-currency support (USD, EUR, GBP, CAD, AUD, JPY, INR, CNY)
- 📤 Share settlement results
- 💸 Flexible expense tracking

## Next Steps

1. Read the [Development Guide](docs/DEVELOPMENT.md)
2. Implement guest mode (local storage)
3. Build game tracking screens
4. Set up Firebase (see [Setup Guide](docs/SETUP_GUIDE.md))

---

For detailed information, see the [complete documentation](docs/README.md).
