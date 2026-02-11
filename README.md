# SplitPot

Smart game tracking and settlement calculator for home games. Track buy-ins, calculate optimized settlements, and share live game standings.

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

📚 **[Complete Documentation](docs/README.md)** - Full documentation index

**Quick Links:**
- [Features](docs/FEATURES.md) - App features and specifications
- [Store Submission](docs/STORE_SUBMISSION_CHECKLIST.md) - Complete submission guide
- [Firebase Hosting](docs/FIREBASE_HOSTING_SETUP.md) - Deploy web viewer
- [Release Signing](docs/ANDROID_RELEASE_SIGNING.md) - Android & iOS signing setup

**Live Links:**
- 🌐 **Website:** https://splitpot.web.app
- 📧 **Support:** project44231@gmail.com
- 🔒 **Privacy:** https://splitpot.web.app/privacy-policy

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

## App Store

- **App Name:** SplitPot
- **Platforms:** iOS, Android
- **Category:** Entertainment
- **Price:** Free

## License

All rights reserved.
