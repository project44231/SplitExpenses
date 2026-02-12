# Project Migration: GameTracker → SplitExpenses

## ⚠️ IMPORTANT
**This project is completely independent from GameTracker.**  
All Firebase artifacts, configurations, and identifiers now use `splitexpenses-4c618` exclusively.

## Migration Summary

### Firebase Project
- **Old**: `gametracker-a834b`
- **New**: `splitexpenses-4c618`

### Bundle Identifiers
- **Android**: `com.splitexpenses.app`
- **iOS**: `com.splitexpenses.app`

### Firebase Hosting
- **URL**: `https://splitexpenses-4c618.web.app`
- **Share URLs**: `https://splitexpenses-4c618.web.app/share/{eventId}/{token}`

## Updated Files

### 1. Firebase Configuration
✅ `lib/firebase/firebase_options.dart` - All platforms now use splitexpenses-4c618
✅ `firebase/firebase.json` - FlutterFire CLI config updated
✅ `.firebaserc` - Default project set to splitexpenses-4c618

### 2. Web Configuration
✅ `web/firebase-config.js` - Web app uses splitexpenses-4c618 config
✅ `web/share.html` - Share page connects to splitexpenses database

### 3. Mobile Configuration
✅ `android/app/build.gradle` - Package name: `com.splitexpenses.app`
✅ `ios/Runner.xcodeproj/project.pbxproj` - Bundle ID: `com.splitexpenses.app`
✅ `android/app/google-services.json` - Generated from splitexpenses-4c618
✅ `ios/Runner/GoogleService-Info.plist` - Generated from splitexpenses-4c618

### 4. Services
✅ `lib/services/event_share_service.dart` - Domain: `splitexpenses-4c618.web.app`

## Firebase Apps Registered

| Platform | App ID | Bundle/Package ID |
|----------|--------|-------------------|
| Web | 1:719860996232:web:cebbab83d23e567d1ba73d | - |
| Android | 1:719860996232:android:99e12273a801d1191ba73d | com.splitexpenses.app |
| iOS | 1:719860996232:ios:8eb876c6b85a0db71ba73d | com.splitexpenses.app |

## Deployment Status

✅ **Firebase Hosting**: Deployed to `splitexpenses-4c618`
✅ **Firestore Rules**: Deployed to `splitexpenses-4c618`
✅ **Web Share Page**: Live at `https://splitexpenses-4c618.web.app`

## Verification Checklist

- [x] No gametracker references in `.dart` files
- [x] No gametracker references in `.json` files
- [x] No gametracker references in `.js` files
- [x] No gametracker references in `.gradle` files
- [x] Firebase options use splitexpenses-4c618
- [x] Web config uses splitexpenses-4c618
- [x] Bundle IDs updated to com.splitexpenses.app
- [x] Firebase hosting deployed to splitexpenses-4c618
- [x] Firestore rules deployed to splitexpenses-4c618

## Future Development

**Remember**: This project must NEVER use gametracker artifacts.

When adding new features or configurations:
- ✅ Use Firebase project: `splitexpenses-4c618`
- ✅ Use bundle ID: `com.splitexpenses.app`
- ✅ Use hosting domain: `splitexpenses-4c618.web.app`
- ❌ Never reference gametracker in any capacity

## Firestore Database

The app now reads/writes to the `splitexpenses-4c618` Firestore database.

**Collections:**
- `events` - Event/group expense data
- `participants` - People in events
- `expenses` - Individual expenses
- `settlements` - Settlement transactions
- `event_groups` - Event groupings
- `feedback` - User feedback

## Notes

- Documentation files in `/docs` may still contain gametracker references as examples
- These are safe to ignore as they don't affect the app's functionality
- Update documentation as needed when creating new guides
