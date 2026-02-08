# Game Tracker

A Flutter-based poker home game tracker with buy-in management, settlements, and statistics.

## Documentation

For detailed documentation, please see the [docs](./docs) folder:

- [Setup Guide](./docs/SETUP.md)
- [Features](./docs/FEATURES.md)
- [Project Status](./docs/STATUS.md)
- [Testing](./docs/TESTING.md)
- [Color Theme](./docs/COLOR_THEME.md)
- [Main Documentation](./docs/README_ROOT.md)

## Quick Start

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Firebase Configuration

Firebase configuration files are located in the `firebase/` folder. Platform-specific configuration files remain in their required locations:
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

## Project Structure

```
lib/
├── core/           # Core utilities, theme, routing
├── features/       # Feature modules (auth, game, history, etc.)
├── firebase/       # Firebase configuration
├── models/         # Data models
└── services/       # Services (storage, settlement, etc.)
```

## License

All rights reserved.
