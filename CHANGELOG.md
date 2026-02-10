# Changelog

All notable changes to the Game buy in tracker app will be documented in this file.

## [Unreleased]

### Added - Google Authentication (2026-02-07)

#### Code Implementation
- **AuthService** (`lib/features/auth/services/auth_service.dart`)
  - Complete Google Sign-In implementation
  - Account picker with automatic sign-out before selection
  - Comprehensive Firebase Auth error handling
  - Automatic guest mode clearance on successful sign-in
  - User profile sync (email, display name, photo URL)

- **AuthScreen** (`lib/features/auth/screens/auth_screen.dart`)
  - Enabled Google Sign-In button
  - Error handling with user-friendly messages
  - Navigation to game screen on successful auth
  - Loading states during authentication

#### Dependencies
- Added `google_sign_in: ^6.2.2` to pubspec.yaml

#### Documentation
- **New**: `docs/GOOGLE_SIGNIN_SETUP.md` - Complete setup guide
  - Firebase Console configuration
  - iOS setup with Info.plist configuration
  - Android setup with SHA-1 fingerprints
  - Testing procedures
  - Troubleshooting for common issues
  - Production deployment checklist
- **New**: `docs/QUICK_START_GOOGLE_AUTH.md` - 10-minute quick start
- Updated: `docs/README.md` - Added authentication guides
- Updated: `docs/STATUS.md` - Marked Google auth as complete

#### Features
- User can sign in with Google account
- Google profile data automatically synced
- Guest data preserved (userId='guest' in Firestore)
- Authenticated data uses Firebase Auth UID
- Smooth transition from guest to authenticated user

### Added - Firebase Integration (2026-02-07)

#### New Services
- **FirestoreService** (`lib/services/firestore_service.dart`)
  - Complete CRUD operations for all data models
  - Real-time stream support (prepared for future use)
  - User-scoped data queries
  - Batch operations for settlements

#### Updated Providers
- **GameProvider** (`lib/features/game/providers/game_provider.dart`)
  - Dual storage: Firestore (primary) + Hive (cache/fallback)
  - Authentication-aware operations
  - Automatic sync to cloud for authenticated users
  - Local-only storage for guest mode
  - Error handling with local fallback

- **PlayerProvider** (`lib/features/players/providers/player_provider.dart`)
  - Same dual storage pattern as GameProvider
  - Cloud sync for authenticated users
  - Guest mode support

#### Architecture
- **Universal Cloud Storage**: 
  - ALL users: Data saved to both Firestore and Hive
  - Guest mode: Uses userId='guest' in Firestore
  - Authenticated: Uses Firebase Auth UID in Firestore
  - Offline support: Automatic fallback to local cache
  - Error resilience: Always falls back to local storage

#### Data Flow
```
User Action → Provider → Firestore (always) → Cloud
                      → Hive (always, as cache)

Guest Mode: userId = 'guest'
Authenticated: userId = Firebase Auth UID
```

#### Guest Data Management
- New: `GuestCleanupService` for managing guest data
- Cleanup methods: Delete old data (>X days) or all guest data
- Stats methods: Track guest data volume
- Separation: Guest and authenticated data fully isolated by userId

#### Documentation
- New: `docs/FIREBASE_INTEGRATION.md` - Complete integration guide
- Updated: `docs/README.md` - Added Firebase integration link
- Updated: `docs/STATUS.md` - Marked Firebase integration as complete

### Fixed
- Deprecated `withOpacity()` replaced with `withValues(alpha:)` in cash_out_screen.dart
- Linter warnings resolved

### Technical Details
- All Firestore documents include `userId` field for security and cleanup
  - Guest mode: userId = 'guest'
  - Authenticated: userId = Firebase Auth UID
- Server-side timestamps (`updatedAt`) for proper sync
- Collection names match data models: `games`, `players`, `buy_ins`, `cash_outs`, `settlements`, `game_groups`, `expenses`
- Guest data cleanup service for storage cost management

## Previous Updates

See `docs/STATUS.md` for full feature history including:
- Player management (edit/delete)
- Custom buy-in amounts
- Cash-out screen conversion
- Settlement optimization
- Guest mode authentication
- And more...
