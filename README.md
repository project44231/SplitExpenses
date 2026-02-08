# Poker Tracker

Track poker buy-ins for home games with ease. Manage players, settlements, and view game history all in one place.

## Features

### Core Features
- 🎮 **Active Game Tracking** - Real-time buy-in management with live game updates
- 💰 **Smart Settlements** - Automatic settlement calculations with debt optimization
- 📊 **Game History** - Complete game history with filters and leaderboards
- 👥 **Player Contacts** - Persistent player list with favorites and statistics
- 💸 **Cash-Out Tracking** - Intelligent mismatch handling and reconciliation
- 🔄 **Optimized Settlements** - Minimized transaction suggestions

### Authenticated User Features
- 📈 **Statistics Dashboard** - Hosting statistics, player leaderboards, ROI tracking
- 🌐 **Live Game Sharing** - Share game standings via web link with real-time updates
- ⭐ **Player Favorites** - Quick access to frequently played contacts
- 🔍 **Advanced Filters** - Filter history by date, player, pot size, and more
- 📱 **Profile Management** - User info, hosting stats, and app settings
- 🔒 **Secure Data** - Firestore security rules for data protection

### Platform Support
- 📱 Cross-platform (iOS & Android)
- 🌐 Web viewer for live game sharing

## Tech Stack

- **Framework:** Flutter
- **State Management:** Riverpod
- **Database:** Firebase (Firestore, Storage, Analytics)
- **Authentication:** Firebase Auth with Google Sign-In
- **Local Storage:** Hive (local cache)
- **Navigation:** GoRouter
- **Data Models:** Freezed
- **Web Hosting:** Firebase Hosting

## Quick Start

```bash
# Install dependencies
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

## Firebase Configuration

Firebase configuration files are located in the `firebase/` folder. Platform-specific configuration files remain in their required locations:
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

## Firebase Deployment

### Deploy Web Viewer (Live Game Sharing)
```bash
firebase deploy --only hosting
```

### Deploy Security Rules
```bash
firebase deploy --only firestore:rules,firestore:indexes
```

### Deploy All
```bash
firebase deploy
```

## Documentation

### Setup Guides
- [Firebase Setup](docs/FIREBASE_SETUP.md) - Firebase configuration guide
- [Google Auth Setup](docs/QUICK_START_GOOGLE_AUTH.md) - Google Sign-In setup
- [Firebase Hosting Setup](docs/FIREBASE_HOSTING_SETUP.md) - Deploy web viewer for live sharing
- [Firestore Security Rules](docs/FIRESTORE_SECURITY_RULES.md) - Security rules and deployment

### Feature Documentation
- [Features](docs/FEATURES.md) - Detailed feature list
- [Game Flow](docs/GAME_FLOW.md) - Game lifecycle and user flow
- [Cash-Out Handling](docs/CASH_OUT_HANDLING.md) - Cash-out reconciliation system
- [Authenticated Features](docs/AUTHENTICATED_FEATURES_IMPLEMENTATION.md) - Comprehensive guide to authenticated user features
- [Project Status](docs/STATUS.md) - Implementation status
- [Testing](docs/TESTING.md) - Testing guide
- [Color Theme](docs/COLOR_THEME.md) - App theme details

## Project Structure

```
lib/
├── core/              # Core utilities, theme, routing
│   ├── constants/     # App-wide constants
│   ├── router/        # GoRouter configuration
│   ├── theme/         # App theme
│   └── utils/         # Utility functions
├── features/          # Feature modules
│   ├── auth/          # Authentication
│   ├── game/          # Game management
│   ├── history/       # Game history & leaderboards
│   ├── players/       # Player contacts
│   └── profile/       # User profile
├── models/            # Data models (Freezed)
└── services/          # Services (Firebase, settlement, etc.)

web/
└── share/             # Web viewer for live game sharing
    ├── index.html     # UI
    └── app.js         # Firebase integration
```

## Development

### Code Generation
This project uses code generation for models and providers:

```bash
# Watch for changes
dart run build_runner watch

# Build once
dart run build_runner build --delete-conflicting-outputs
```

### Testing
```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## License

All rights reserved.
