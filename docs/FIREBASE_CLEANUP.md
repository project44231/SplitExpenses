# Firebase Data Cleanup Guide

This guide explains how to delete all data from Firebase for fresh testing.

## Quick Cleanup Steps

### 1. Firestore Database Cleanup

**Option A: Delete Individual Collections (Safer)**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `gametracker-a834b`
3. Navigate to **Firestore Database**
4. Delete each collection:
   - Click on collection name (games, players, buy_ins, etc.)
   - Click the three dots menu (⋮)
   - Select "Delete collection"
   - Confirm deletion

Collections to delete:
- `games`
- `players`
- `buy_ins`
- `cash_outs`
- `settlements`
- `expenses`
- `reconciliations`
- `game_groups`

**Option B: Delete Entire Database (Nuclear Option)**

⚠️ **WARNING:** This deletes ALL data and cannot be undone!

1. Go to Firebase Console → Firestore Database
2. Click **Settings** (gear icon)
3. Scroll to "Delete database"
4. Type database name to confirm
5. Click "Delete database"
6. Wait a few seconds, then create a new database

### 2. Firebase Authentication Cleanup

**Delete Test Users:**

1. Go to Firebase Console → Authentication
2. Go to **Users** tab
3. For each test user:
   - Click the three dots (⋮)
   - Select "Delete account"
   - Confirm

**OR Delete All Users:**

1. Select multiple users with checkboxes
2. Click "Delete selected users"

### 3. Firebase Storage Cleanup (if used)

1. Go to Firebase Console → Storage
2. Navigate through folders:
   - `users/` - user uploads
   - `games/` - game-related files
3. Select files/folders
4. Click Delete icon (🗑️)

### 4. Clear Local App Data

**Android Emulator:**
```bash
# Uninstall and reinstall
flutter run -d emulator-5554 --uninstall-first
```

**iOS Simulator:**
```bash
# Reset simulator
xcrun simctl erase all

# Or uninstall and reinstall
flutter run -d <device-id> --uninstall-first
```

**Clear Local Storage:**
- Guest mode data is stored in Hive
- App data will be cleared when you uninstall

## Using Firebase CLI (Advanced)

### Delete Firestore Data Programmatically

**Install Firebase Tools:**
```bash
npm install -g firebase-tools
firebase login
```

**Delete All Documents in a Collection:**

Create `scripts/cleanup-firestore.js`:
```javascript
const admin = require('firebase-admin');
const serviceAccount = require('../path/to/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function deleteCollection(collectionPath, batchSize = 100) {
  const collectionRef = db.collection(collectionPath);
  const query = collectionRef.limit(batchSize);

  return new Promise((resolve, reject) => {
    deleteQueryBatch(db, query, resolve).catch(reject);
  });
}

async function deleteQueryBatch(db, query, resolve) {
  const snapshot = await query.get();

  const batchSize = snapshot.size;
  if (batchSize === 0) {
    resolve();
    return;
  }

  const batch = db.batch();
  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });
  await batch.commit();

  process.nextTick(() => {
    deleteQueryBatch(db, query, resolve);
  });
}

// Delete all collections
async function cleanupAll() {
  const collections = [
    'games',
    'players',
    'buy_ins',
    'cash_outs',
    'settlements',
    'expenses',
    'reconciliations',
    'game_groups'
  ];

  for (const collection of collections) {
    console.log(`Deleting ${collection}...`);
    await deleteCollection(collection);
    console.log(`✓ ${collection} deleted`);
  }

  console.log('All collections deleted!');
  process.exit(0);
}

cleanupAll();
```

**Run:**
```bash
node scripts/cleanup-firestore.js
```

## Quick Commands Reference

```bash
# Clean reinstall app (clears local data)
flutter clean
flutter pub get
flutter run --uninstall-first

# Deploy fresh security rules
firebase deploy --only firestore:rules

# Deploy fresh indexes
firebase deploy --only firestore:indexes
```

## After Cleanup Checklist

- [ ] All Firestore collections deleted
- [ ] Test users removed from Authentication
- [ ] Storage files deleted (if any)
- [ ] App uninstalled from device/emulator
- [ ] Fresh app install completed
- [ ] Security rules deployed
- [ ] Indexes deployed

## Common Issues After Cleanup

### Issue: "Index required" errors
**Solution:** Click the link in the error or run:
```bash
firebase deploy --only firestore:indexes
```

### Issue: Authentication not working
**Solution:** 
1. Check Google Sign-In is enabled in Firebase Console
2. Verify SHA certificates are configured
3. Re-download `google-services.json` if needed

### Issue: App still shows old data
**Solution:**
```bash
# Clear app data completely
flutter clean
rm -rf build/
flutter run --uninstall-first
```

## Testing Fresh Start

1. **Sign in as Guest**
   - Create a test game
   - Add players and buy-ins
   - Verify data appears in Firebase Console

2. **Sign in with Google**
   - Create another test game
   - Verify separation from guest data
   - Check History and Profile screens

3. **Test Live Sharing**
   - Share a game
   - Open link in browser
   - Verify real-time updates

## Emergency: Restore from Backup

If you need to restore data:

1. **Firestore doesn't auto-backup** - you'll need to implement exports
2. **Manual export:**
   - Firebase Console → Firestore → Import/Export
   - Export to Cloud Storage bucket
   - Import when needed

3. **Automated backups:**
   - Use Cloud Functions for scheduled backups
   - Set up Cloud Storage lifecycle rules
