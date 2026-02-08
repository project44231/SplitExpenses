# Firebase Integration Guide

## Overview

The app now integrates with Firebase Firestore to store **ALL game data** in the cloud, regardless of guest or authenticated mode. This provides:

- **Universal Cloud Backup**: All game data is automatically backed up to Firestore (guest + authenticated)
- **Multi-Device Sync**: Access your game history from any device when logged in
- **Offline Support**: Local Hive storage provides offline fallback
- **Guest Mode**: Works seamlessly with Firestore, using 'guest' as userId
- **Easy Cleanup**: Guest data can be cleaned up separately from authenticated user data

## Architecture

### Dual Storage Strategy

The app uses a dual storage approach for ALL users:

1. **Firestore (Primary)**: All data saved to cloud (guest mode uses userId='guest')
2. **Hive (Secondary)**: Local cache for offline access and performance

### Data Flow

```
User Action → Provider → Firestore Service (always) → Firestore
                      ↓
                      → Local Storage Service → Hive (cache)

Guest Mode: userId = 'guest'
Authenticated: userId = Firebase Auth UID
```

## Implementation Details

### Services

#### FirestoreService (`lib/services/firestore_service.dart`)

Handles all Firebase Firestore operations:

- **Games**: CRUD operations, real-time streams
- **Players**: User-specific player management
- **Buy-Ins**: Track all buy-ins per game
- **Cash-Outs**: Settlement amounts
- **Settlements**: Optimized payment transfers
- **Game Groups**: Organize games into groups

Each document includes:
- `userId`: Links data to the authenticated user
- `updatedAt`: Server timestamp for sync

#### LocalStorageService (`lib/services/local_storage_service.dart`)

Unchanged - continues to provide local Hive storage for:
- Guest mode
- Offline caching
- Fast local access

### Providers

#### GameProvider

Updated to:
- Check authentication status before operations
- Save to both Firestore and local storage
- Load from Firestore for authenticated users
- Fallback to local storage on errors
- Cache Firestore data locally for offline access

#### PlayerProvider

Updated with same dual storage pattern as GameProvider.

### User ID Assignment

Both providers assign userId based on authentication status:

```dart
String get _userId => _authService.currentUserId ?? 'guest';
```

- **Guest Mode**: userId = 'guest'
- **Authenticated**: userId = Firebase Auth UID

**All operations save to both Firestore and Hive**, regardless of mode.

## Firestore Collections

### `games`
- Document ID: Game UUID
- Fields: All Game model fields + `userId`, `updatedAt`

### `players`
- Document ID: Player UUID
- Fields: All Player model fields + `userId`, `updatedAt`

### `buy_ins`
- Document ID: BuyIn UUID
- Fields: All BuyIn model fields + `userId`, `gameId`, `updatedAt`

### `cash_outs`
- Document ID: CashOut UUID
- Fields: All CashOut model fields + `userId`, `gameId`, `updatedAt`

### `settlements`
- Document ID: Settlement UUID
- Fields: All Settlement model fields + `userId`, `gameId`, `updatedAt`

### `game_groups`
- Document ID: GameGroup UUID
- Fields: All GameGroup model fields + `userId`, `updatedAt`

### `expenses`
- Document ID: Expense UUID
- Fields: All Expense model fields + `userId`, `gameId`, `updatedAt`

## Security Rules (Recommended)

Add these rules to your Firestore console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check authentication
    function isSignedIn() {
      return request.auth != null;
    }
    
    // Helper function to check ownership
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Games collection
    match /games/{gameId} {
      allow read, write: if isSignedIn() && isOwner(resource.data.userId);
      allow create: if isSignedIn() && isOwner(request.resource.data.userId);
    }
    
    // Players collection
    match /players/{playerId} {
      allow read, write: if isSignedIn() && isOwner(resource.data.userId);
      allow create: if isSignedIn() && isOwner(request.resource.data.userId);
    }
    
    // Buy-ins collection
    match /buy_ins/{buyInId} {
      allow read, write: if isSignedIn() && isOwner(resource.data.userId);
      allow create: if isSignedIn() && isOwner(request.resource.data.userId);
    }
    
    // Cash-outs collection
    match /cash_outs/{cashOutId} {
      allow read, write: if isSignedIn() && isOwner(resource.data.userId);
      allow create: if isSignedIn() && isOwner(request.resource.data.userId);
    }
    
    // Settlements collection
    match /settlements/{settlementId} {
      allow read, write: if isSignedIn() && isOwner(resource.data.userId);
      allow create: if isSignedIn() && isOwner(request.resource.data.userId);
    }
    
    // Game groups collection
    match /game_groups/{groupId} {
      allow read, write: if isSignedIn() && isOwner(resource.data.userId);
      allow create: if isSignedIn() && isOwner(request.resource.data.userId);
    }
    
    // Expenses collection
    match /expenses/{expenseId} {
      allow read, write: if isSignedIn() && isOwner(resource.data.userId);
      allow create: if isSignedIn() && isOwner(request.resource.data.userId);
    }
  }
}
```

## Error Handling

All Firestore operations include try-catch blocks with local storage fallback:

```dart
try {
  if (_isAuthenticated) {
    // Try Firestore first
    final data = await _firestoreService.getData();
    // Cache locally
    await _localStorage.saveData(data);
    return data;
  }
  return await _localStorage.getData();
} catch (e) {
  // Fallback to local storage on error
  return await _localStorage.getData();
}
```

This ensures the app continues to work even if:
- Network is unavailable
- Firestore is down
- User is offline

## Testing

### Guest Mode
1. Launch app
2. Click "Continue as Guest"
3. All data saved locally only

### Authenticated Mode
1. Launch app
2. Sign in with Firebase Auth
3. All data saved to both Firestore and locally
4. Check Firebase Console to verify data

### Offline Mode
1. Sign in while online
2. Create some games
3. Turn off network
4. App continues to work from local cache

## Migration Notes

No migration needed! Existing local data continues to work:
- All new operations save to both Firestore and Hive
- Guest users: New data goes to Firestore with userId='guest'
- When user signs in: Next operations will use their Firebase Auth UID
- Previous local-only games remain in Hive until explicitly synced

## Future Enhancements

Potential future improvements:
- Real-time sync using Firestore streams
- Background sync for offline changes
- Conflict resolution for multi-device edits
- Manual data migration tool (local → Firestore)
