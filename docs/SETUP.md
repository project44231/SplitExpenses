# Setup Guide - Game buy-in tracker

This guide will walk you through setting up the Game buy-in tracker app from scratch.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Firebase Configuration](#firebase-configuration)
4. [Running the App](#running-the-app)
5. [Testing](#testing)
6. [Next Steps](#next-steps)

## Prerequisites

### Required Software

1. **Flutter SDK** (3.x or later)
   ```bash
   # Check your Flutter installation
   flutter doctor
   ```
   
   If you don't have Flutter:
   - Visit https://docs.flutter.dev/get-started/install
   - Download and install for your platform
   - Add Flutter to your PATH

2. **Dart** (included with Flutter)
   ```bash
   dart --version
   ```

3. **IDE** (choose one):
   - VS Code with Flutter extension
   - Android Studio with Flutter plugin
   - IntelliJ IDEA with Flutter plugin

4. **Platform-specific tools**:
   
   **For iOS development:**
   - macOS computer
   - Xcode 14+ (from Mac App Store)
   - CocoaPods
   ```bash
   sudo gem install cocoapods
   ```
   
   **For Android development:**
   - Android Studio
   - Android SDK (API 21+)
   - Android Emulator OR physical device

5. **Firebase Account**
   - Go to https://firebase.google.com/
   - Sign in with your Google account

## Initial Setup

### Step 1: Verify Installation

```bash
cd /Users/hanish/Documents/Projects/AI_PROJECTS/gametracker

# Install dependencies
flutter pub get

# Verify everything works
flutter doctor -v
```

**Expected output:**
- ✅ Flutter (Channel stable)
- ✅ Android toolchain
- ✅ Xcode (if on macOS)
- ✅ VS Code / Android Studio

### Step 2: Generate Model Code

```bash
# Generate Freezed code for models
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `.freezed.dart` files (immutable model classes)
- `.g.dart` files (JSON serialization)

**If you see errors**, run:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 3: Verify Build

```bash
# Analyze code
flutter analyze

# Run tests
flutter test
```

Both should pass with no errors.

## Firebase Configuration

### Step 1: Create Firebase Project

1. Go to https://console.firebase.google.com/
2. Click **"Add project"**
3. Enter project name: `poker-tracker` (or your choice)
4. Click "Continue"
5. **Google Analytics**: Enable (recommended)
   - Choose or create an Analytics account
6. Click "Create project"
7. Wait for project to be created (30-60 seconds)
8. Click "Continue"

### Step 2: Register Your App

#### For iOS:

1. In Firebase Console, click iOS icon
2. **iOS bundle ID**: `com.gametracker.pokerTracker`
   - Find this in `ios/Runner.xcodeproj/project.pbxproj`
   - Or in Xcode: Runner → General → Bundle Identifier
3. **App nickname**: "Game buy-in tracker iOS" (optional)
4. **App Store ID**: Leave blank for now
5. Click "Register app"
6. **Download** `GoogleService-Info.plist`
7. Open `ios/Runner.xcworkspace` in Xcode
8. Drag `GoogleService-Info.plist` into Runner folder in Xcode
   - ✅ Check "Copy items if needed"
   - ✅ Select "Runner" target
9. Click "Next" through remaining steps

#### For Android:

1. In Firebase Console, click Android icon
2. **Android package name**: `com.gametracker.poker_tracker`
   - Find in `android/app/build.gradle` → `applicationId`
3. **App nickname**: "Game buy-in tracker Android" (optional)
4. **SHA-1**: Leave blank for now (needed later for Google Sign In)
5. Click "Register app"
6. **Download** `google-services.json`
7. Copy file to: `android/app/google-services.json`
8. Click "Next" through remaining steps

### Step 3: Install FlutterFire CLI

```bash
# Install FlutterFire CLI globally
dart pub global activate flutterfire_cli

# Verify installation
flutterfire --version
```

If `flutterfire` command not found, add to PATH:
```bash
# macOS/Linux
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Add to ~/.zshrc or ~/.bashrc to persist
echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc
```

### Step 4: Configure FlutterFire

```bash
# Run FlutterFire configuration
flutterfire configure
```

**Follow prompts:**
1. Select your Firebase project: `poker-tracker`
2. Select platforms:
   - ✅ android
   - ✅ ios
   - ⬜ macos (not needed)
   - ⬜ web (not needed for now)

**This creates:**
- `lib/firebase_options.dart` (Firebase configuration)
- Updates platform-specific files

### Step 5: Enable Firebase Services

#### Firestore Database

1. Firebase Console → Build → **Firestore Database**
2. Click "Create database"
3. **Location**: Choose closest to your users
4. **Security rules**: Start in **test mode**
   - This allows read/write for development
   - We'll update rules later
5. Click "Enable"
6. Wait for database to be created

#### Authentication

1. Firebase Console → Build → **Authentication**
2. Click "Get started"
3. Click "Sign-in method" tab
4. Enable sign-in providers:

**Email/Password:**
- Click "Email/Password"
- Toggle "Enable"
- Click "Save"

**Google:**
- Click "Google"
- Toggle "Enable"
- Set support email (your email)
- Click "Save"

**Apple (iOS only):**
- Click "Apple"
- Toggle "Enable"
- Enter your details
- Click "Save"

#### Cloud Storage

1. Firebase Console → Build → **Storage**
2. Click "Get started"
3. **Security rules**: Start in **test mode**
4. **Location**: Same as Firestore
5. Click "Done"

#### Analytics (Already enabled)

1. Firebase Console → Analytics → **Dashboard**
2. Verify events are being collected (after running app)

### Step 6: Update App Code

**Enable Firebase in `lib/main.dart`:**

Find this section:
```dart
// TODO: Initialize Firebase
// await Firebase.initializeApp(
//   options: DefaultFirebaseOptions.currentPlatform,
// );
```

Uncomment it:
```dart
// Initialize Firebase
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

**Add import at top of `lib/main.dart`:**
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
```

### Step 7: Verify Firebase Connection

```bash
# Run the app
flutter run

# Check console for:
# "Firebase initialized successfully" (or similar)
```

## Running the App

### On iOS Simulator

```bash
# List available simulators
xcrun simctl list devices

# Start a simulator (if not running)
open -a Simulator

# Run app
flutter run -d <device-id>
# OR just
flutter run
```

### On Android Emulator

```bash
# List available emulators
flutter emulators

# Launch an emulator
flutter emulators --launch <emulator-id>

# Run app
flutter run
```

### On Physical Device

**iOS:**
1. Connect iPhone via USB
2. Trust computer on iPhone
3. In Xcode, select your development team
4. Run: `flutter run`

**Android:**
1. Enable Developer Options on Android phone
2. Enable USB Debugging
3. Connect via USB
4. Run: `flutter run`

## Testing

### Test Firebase Connection

1. Run the app
2. Create a test account (if auth is enabled)
3. Check Firebase Console:
   - **Authentication** → Users tab (should show your user)
   - **Firestore** → Data tab (will populate when you create games)
   - **Analytics** → Events (should show app_open events)

### Test Core Features

Once implemented:
1. **Create Game** → Should save to Firestore
2. **Add Buy-ins** → Should update game data
3. **End Game** → Should calculate settlements
4. **View History** → Should load from Firestore

## Next Steps

Now that your environment is set up:

### Phase 1 Implementation
1. **Implement Guest Mode**
   - Use Hive for local storage
   - Create guest user provider

2. **Build Game Screens**
   - New Game screen (select players, start game)
   - Active Game screen (track buy-ins, show totals)
   - Settlement screen (show optimized settlements)

3. **Integrate Firestore**
   - Create Firestore service
   - Implement CRUD operations
   - Handle real-time updates

4. **Add History**
   - List past games
   - Game details view
   - Player statistics

### Development Workflow

```bash
# Always start with:
flutter pub get

# When you modify models:
flutter pub run build_runner watch  # Auto-rebuilds on changes

# Before committing:
flutter analyze
flutter test
```

### Git Workflow

```bash
# Initialize git (if not already)
git init

# Add .gitignore (already created)
git add .
git commit -m "Initial commit - Phase 1 foundation"

# Create repo on GitHub and push
git remote add origin <your-repo-url>
git push -u origin main
```

### Important Files to NOT Commit

These are already in `.gitignore`:
- `firebase_options.dart` (regenerate per environment)
- `GoogleService-Info.plist` (iOS)
- `google-services.json` (Android)
- API keys and secrets

## Troubleshooting

### Firebase Not Working

**Issue**: "Firebase not initialized" error

**Solution**:
1. Check `firebase_options.dart` exists
2. Verify import in `main.dart`
3. Ensure Firebase.initializeApp() is called before runApp()
4. Run: `flutterfire configure` again

### Build Errors

**Issue**: "CocoaPods not found" (iOS)

**Solution**:
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
flutter clean
flutter run
```

**Issue**: "Gradle build failed" (Android)

**Solution**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Code Generation Issues

**Issue**: Freezed files not generating

**Solution**:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## Need Help?

- **Flutter Docs**: https://docs.flutter.dev/
- **Firebase Docs**: https://firebase.google.com/docs/flutter
- **Riverpod Docs**: https://riverpod.dev/
- **Stack Overflow**: Tag your questions with `flutter`, `firebase`, `riverpod`

## Summary

✅ **You've completed:**
- Flutter environment setup
- Firebase project creation
- Firebase services configuration
- App compiles and runs
- Basic UI structure

🚧 **Next:**
- Implement guest mode
- Build game tracking screens
- Add Firestore integration
- Create history views

🎉 **Ready to build!** Start with implementing the New Game screen.
