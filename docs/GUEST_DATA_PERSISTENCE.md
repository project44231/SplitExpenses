# Guest Data Persistence to Firebase

## Overview
Updated guest user flow to persist data to Firebase Firestore, providing cloud backup and enabling future account migration.

## What Changed

### Previous Behavior
- **Guest users**: Local storage only (Hive)
- **Authenticated users**: Firestore + local cache
- **Problem**: Guest data lost on cache clear, no multi-device support

### New Behavior
- **Both guest and authenticated users**: Firestore + local cache
- **Benefits**:
  - ✅ Guest data backed up to cloud
  - ✅ Survives cache clear/reinstall
  - ✅ Multi-device access with same guest ID
  - ✅ Easy migration to authenticated account
  - ✅ GuestCleanupService automatically removes old data

## Files Modified

### 1. `lib/services/local_storage_service.dart`
**Added**: `getSettlementsByGame()` method for local settlement retrieval
- Returns all settlements for a game sorted by date
- Enables offline settlement access

### 2. `lib/features/game/providers/game_provider.dart`
**Removed**: All `if (!_isGuestMode)` blocks that prevented Firestore access

**Changes**:
- `loadGames()` - Both guest and authenticated load from Firestore
- `createGame()` - Guest games now saved to Firestore
- `endGame()` - Guest game updates persisted to Firestore
- `deleteGame()` - Guest games deleted from Firestore
- `getGame()` - Tries Firestore first, fallback to local
- `getBuyIns()` - Loads from Firestore for all users
- `getCashOuts()` - Loads from Firestore for all users
- `addBuyIn()` - Saves to Firestore for all users
- `updateBuyIn()` - Updates Firestore for all users
- `deleteBuyIn()` - Deletes from Firestore for all users
- `addCashOut()` - Saves to Firestore for all users
- `clearCashOuts()` - Clears from Firestore for all users
- `updateGame()` - Updates Firestore for all users
- `saveSettlement()` - Now saves locally AND to Firestore for guests
- `getSettlements()` - Loads from Firestore with local fallback for guests
- `updateGameNotes()` - Updates Firestore for all users
- `updateGameName()` - Updates Firestore for all users

### 3. `lib/features/players/providers/player_provider.dart`
**Removed**: All `if (!_isGuestMode)` blocks

**Changes**:
- `loadPlayers()` - Both guest and authenticated load from Firestore
- `addPlayer()` - Guest players saved to Firestore
- `updatePlayer()` - Guest player updates persisted to Firestore
- `deletePlayer()` - Guest players deleted from Firestore

### 4. `.cursor/rules/guest-mode-pattern.mdc`
**Updated**: Documentation to reflect new pattern
- Updated save/load patterns
- Added benefits section
- Removed "never let guest users access Firestore" rule
- Added Firestore rules explanation

## Data Flow

### Create Game (Guest User)
```
1. User creates game
2. Save to local storage (instant feedback)
3. Save to Firestore with userId='guest_xxxxx'
4. Data now in both locations
```

### Load Games (Guest User)
```
1. Try Firestore first with userId='guest_xxxxx'
2. Cache results locally
3. On error: fallback to local storage (offline mode)
```

### Add Player (Guest User)
```
1. User adds player
2. Save to local storage
3. Save to Firestore with userId='guest_xxxxx'
4. Reload players from Firestore
```

## Security

### Firestore Rules
Guest users are identified by userId pattern matching:
- `userId.matches('guest(_.*)?')` - matches 'guest' or 'guest_xxxxx'
- Guest users can only access their own data
- Data isolated by userId field in all documents

### Guest User ID
- Format: `guest_<timestamp>` (e.g., `guest_1707456789123`)
- Generated once per device
- Stored in local preferences
- Consistent across app sessions

## Migration Path

### Future: Guest to Authenticated
When a guest user signs up:
```dart
Future<void> migrateGuestDataToAuthenticated(String newUserId) async {
  // 1. Get all guest data from Firestore (userId = 'guest_xxxxx')
  // 2. Update userId field to new authenticated userId
  // 3. Re-save documents with new userId
  // 4. Delete old guest documents
  // 5. Update local storage flag
}
```

## Testing

### Manual Test Cases
1. **Create game as guest**
   - ✓ Appears immediately (local storage)
   - ✓ Persists to Firestore
   - ✓ Reload app - game still there

2. **Add players as guest**
   - ✓ Save locally and to Firestore
   - ✓ Clear app cache - data persists

3. **Add buy-ins/cash-outs as guest**
   - ✓ All transactions saved to Firestore
   - ✓ Settlements calculated and saved

4. **Offline mode**
   - ✓ Load from local storage when offline
   - ✓ Sync to Firestore when back online

5. **Multi-device (same guest ID)**
   - ✓ Export guest ID to second device
   - ✓ Data appears on both devices

## Cost Implications

### Firestore Usage
**Increased writes**: Guest users now write to Firestore
- Estimate: ~10-20 writes per game session
- Cost: $0.18 per 100K writes

**Storage**: Guest data accumulates over time
- Mitigation: GuestCleanupService removes old data
- Recommended: Run cleanup every 30 days
- See: `docs/GUEST_DATA_CLEANUP.md`

### Recommendations
1. Monitor Firestore usage in Firebase Console
2. Set up billing alerts
3. Run GuestCleanupService monthly
4. Consider retention policy (30-90 days)

## Benefits Summary

| Feature | Before | After |
|---------|--------|-------|
| Guest data persistence | Local only | Cloud + local |
| Survives cache clear | ❌ No | ✅ Yes |
| Multi-device support | ❌ No | ✅ Yes (with ID export) |
| Offline mode | ✅ Yes | ✅ Yes (improved) |
| Account migration | ❌ Difficult | ✅ Easy |
| Data cleanup | ❌ Manual | ✅ Automated |
| Settlement tracking | ❌ No (guest) | ✅ Yes |

## Next Steps

### Immediate
- [x] Update providers to save guest data to Firestore
- [x] Add settlement support for guest users
- [x] Update documentation

### Future Enhancements
1. Implement guest-to-authenticated migration
2. Add guest ID export/import feature
3. Add guest data size monitoring
4. Implement automatic cleanup scheduling
5. Add guest data analytics

## Rollback Plan

If issues arise, revert by:
1. Add back `if (!_isGuestMode)` checks
2. Revert pattern documentation
3. Guest users return to local-only storage

## References
- `docs/GUEST_DATA_CLEANUP.md` - Cleanup service documentation
- `firestore.rules` - Security rules for guest access
- `.cursor/rules/guest-mode-pattern.mdc` - Development pattern
