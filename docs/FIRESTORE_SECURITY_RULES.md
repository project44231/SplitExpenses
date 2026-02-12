# Firestore Security Rules

This document explains the security rules implemented for the app's Firestore database.

## Overview

The security rules ensure that:
- Users can only access their own data
- Guest users can access guest-mode data
- Shared games are publicly readable via share tokens
- All write operations require ownership verification

## Files

- `firestore.rules` - Main security rules for Firestore
- `firestore.indexes.json` - Database indexes for query optimization
- `storage.rules` - Security rules for Firebase Storage

## Deployment

### Deploy Security Rules

```bash
# Deploy Firestore rules only
firebase deploy --only firestore:rules

# Deploy Firestore indexes only
firebase deploy --only firestore:indexes

# Deploy Storage rules only
firebase deploy --only storage

# Deploy all
firebase deploy
```

### Verify Deployment

1. Go to Firebase Console → Firestore → Rules
2. Check that rules show "Active" status
3. Verify the timestamp matches your deployment

## Rule Structure

### Games Collection

```
✅ Read: Owner OR Guest OR Has valid shareToken
✅ Create: Authenticated OR Guest mode
✅ Update/Delete: Owner only
```

**Public Sharing:**
Games with a `shareToken` field are publicly readable for live game sharing. The web viewer validates the token before displaying data.

### Players Collection

```
✅ Read: Owner OR Guest
✅ Create: Authenticated OR Guest mode
✅ Update/Delete: Owner only
```

**Player Contacts:**
Authenticated users have persistent participant contacts. Guest participants are temporary and can be cleaned up.

### Expenses and Settlements

```
✅ Read: Owner OR Guest OR Game has shareToken
✅ Create: Authenticated OR Guest mode
✅ Update/Delete: Owner only
```

**Live Sharing:**
Expenses are readable if the associated event has a valid shareToken, enabling real-time updates in the web viewer.

### Expenses & Reconciliations

```
✅ Read: Owner OR Guest
✅ Create: Authenticated OR Guest mode
✅ Update/Delete: Owner only
```

### Game Groups

```
✅ Read: Owner OR Guest
✅ Create: Authenticated OR Guest mode
✅ Update/Delete: Owner only
```

## Helper Functions

### `isAuthenticated()`
Checks if a user is signed in with Firebase Auth.

### `isOwner(userId)`
Verifies the authenticated user's ID matches the resource owner.

### `isOwnerOrGuest(userId)`
Allows access if the resource is owned by guest mode or the current user.

### `hasValidShareToken(gameId, shareToken)`
Validates that a game's shareToken matches the provided token.

## Testing Rules

### Local Testing (Firebase Emulator)

```bash
# Start emulator
firebase emulators:start

# Run tests (if you have test files)
firebase emulators:exec --only firestore "npm test"
```

### Manual Testing

1. **Guest Mode:**
   - Create a game without signing in
   - Verify you can read/write the game
   - Sign in and verify you can't see the guest game

2. **Authenticated Mode:**
   - Sign in and create a game
   - Sign out and verify you can't access the game
   - Sign in as different user and verify no access

3. **Game Sharing:**
   - Create a game and generate a share link
   - Open the link in incognito mode
   - Verify you can view game data
   - Try accessing without the token (should fail)

## Security Considerations

### Current Implementation

✅ **User Data Isolation:** Users can only access their own games and players
✅ **Guest Mode Support:** Guest data is isolated and can be cleaned up
✅ **Public Sharing:** Share tokens enable read-only public access
✅ **Write Protection:** All modifications require ownership verification

### Future Enhancements

🔄 **Rate Limiting:** Consider adding rate limits for public share links
🔄 **Token Expiration:** Implement time-based token expiration if needed
🔄 **Audit Logging:** Track suspicious access patterns
🔄 **Data Validation:** Add field-level validation rules

## Common Issues

### Issue: "Permission denied" when accessing game

**Cause:** User doesn't own the game or game is owned by guest.

**Solution:** 
- Verify `userId` field matches authenticated user
- Check if game is from guest mode session

### Issue: Shared game not accessible

**Cause:** Share token missing or invalid.

**Solution:**
- Regenerate share link from the app
- Verify `shareToken` field exists in Firestore
- Check URL format: `/share/{eventId}/{shareToken}`

### Issue: Can't update expenses

**Cause:** User doesn't own the event.

**Solution:**
- Verify game ownership
- Check if authenticated with correct account

## Index Requirements

The `firestore.indexes.json` file defines composite indexes for:

- **Events:** Query by `userId`, `status`, and `endTime` (for history)
- **Expenses:** Query by `eventId` and `timestamp` (for ordering)
- **Settlements:** Query by `eventId` and `timestamp` (for ordering)
- **Players:** Query by `userId`, `isFavorite`, and `name` (for contacts)

These indexes are automatically created when deployed.

## Maintenance

### Regular Tasks

1. **Review Access Logs:** Check for unusual access patterns
2. **Clean Guest Data:** Periodically delete old guest games
3. **Monitor Usage:** Track read/write operations
4. **Update Rules:** Adjust as features are added

### Guest Data Cleanup

Consider implementing a Cloud Function to:
- Delete events older than 7 days (guest only)
- Remove orphaned participants and expenses
- Archive instead of delete if needed

## Resources

- [Firestore Security Rules Reference](https://firebase.google.com/docs/firestore/security/get-started)
- [Testing Rules](https://firebase.google.com/docs/rules/unit-tests)
- [Best Practices](https://firebase.google.com/docs/firestore/security/rules-conditions)
