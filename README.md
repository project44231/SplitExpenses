# SplitExpenses

Smart expense splitting app for groups, trips, and events. Track expenses, calculate optimized settlements, and share live expense summaries.

## Features

### Core Features
- 💰 **Expense Tracking** - Real-time expense management with categories
- 🎯 **Smart Settlements** - Automatic settlement calculations with debt optimization
- 📊 **Event History** - Complete event history with filters and statistics
- 👥 **Participant Contacts** - Persistent participant list with favorites
- 💸 **Split Methods** - Equal, percentage, exact amount, and shares-based splitting
- 🔄 **Optimized Settlements** - Minimized transaction suggestions

### Authenticated User Features
- 📈 **Statistics Dashboard** - Event statistics, participant summaries, expense tracking
- 🌐 **Live Event Sharing** - Share event expenses via web link with real-time updates
- ⭐ **Participant Favorites** - Quick access to frequent contacts
- 🔍 **Advanced Filters** - Filter history by date, participant, category, and more
- 📱 **Profile Management** - User info, event stats, and app settings
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
