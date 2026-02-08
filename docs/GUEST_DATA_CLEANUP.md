# Guest Data Cleanup Guide

## Overview

Since all game data (including guest mode) is stored in Firebase Firestore, you can manage storage costs by periodically cleaning up old guest data. Authenticated user data is never affected as it uses a different userId.

## Why Clean Up Guest Data?

- **Storage Costs**: Firestore charges for stored data
- **Performance**: Smaller database = faster queries
- **Privacy**: Remove old anonymous game data
- **Data Hygiene**: Keep only relevant data

## GuestCleanupService

Location: `lib/services/guest_cleanup_service.dart`

### Methods

#### 1. Delete Old Guest Data

Remove guest data older than a specified number of days:

```dart
import 'package:gametracker/services/guest_cleanup_service.dart';

final cleanupService = GuestCleanupService();

// Delete guest data older than 30 days
await cleanupService.deleteOldGuestData(olderThanDays: 30);

// Delete guest data older than 7 days
await cleanupService.deleteOldGuestData(olderThanDays: 7);

// Delete guest data older than 90 days
await cleanupService.deleteOldGuestData(olderThanDays: 90);
```

#### 2. Delete All Guest Data

Remove all guest data regardless of age:

```dart
final cleanupService = GuestCleanupService();

// WARNING: This deletes ALL guest data!
await cleanupService.deleteAllGuestData();
```

#### 3. Get Guest Data Statistics

Check how much guest data exists before cleanup:

```dart
final cleanupService = GuestCleanupService();

final stats = await cleanupService.getGuestDataStats();
print(stats);
// Output:
// {
//   'games': 150,
//   'players': 45,
//   'buy_ins': 380,
//   'cash_outs': 120,
//   'settlements': 150,
//   'expenses': 25,
//   'game_groups': 3
// }

// Check specific collection
final gamesCount = await cleanupService.getGuestDataCount('games');
print('Guest games: $gamesCount');
```

## Recommended Cleanup Strategies

### Strategy 1: Weekly Cleanup (Aggressive)
Best for: Apps with high guest usage

```dart
// Run every week, delete data older than 7 days
await cleanupService.deleteOldGuestData(olderThanDays: 7);
```

### Strategy 2: Monthly Cleanup (Moderate)
Best for: Balanced approach

```dart
// Run every month, delete data older than 30 days
await cleanupService.deleteOldGuestData(olderThanDays: 30);
```

### Strategy 3: Quarterly Cleanup (Conservative)
Best for: Low guest usage or generous storage budget

```dart
// Run every 3 months, delete data older than 90 days
await cleanupService.deleteOldGuestData(olderThanDays: 90);
```

## Firebase Cloud Function (Automated)

For production apps, use a Firebase Cloud Function to automate cleanup:

### Setup

1. Install Firebase CLI:
```bash
npm install -g firebase-tools
firebase init functions
```

2. Create `functions/index.js`:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Run every 7 days at 2 AM
exports.cleanupGuestData = functions.pubsub
  .schedule('0 2 * * 0') // Every Sunday at 2 AM
  .timeZone('America/New_York')
  .onRun(async (context) => {
    console.log('Starting guest data cleanup...');
    
    const db = admin.firestore();
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - 30); // 30 days ago
    
    const collections = [
      'games',
      'players',
      'buy_ins',
      'cash_outs',
      'settlements',
      'expenses',
      'game_groups'
    ];
    
    let totalDeleted = 0;
    
    for (const collectionName of collections) {
      const snapshot = await db.collection(collectionName)
        .where('userId', '==', 'guest')
        .where('updatedAt', '<', admin.firestore.Timestamp.fromDate(cutoffDate))
        .get();
      
      console.log(`Found ${snapshot.size} guest ${collectionName} to delete`);
      
      // Batch delete (max 500 per batch)
      const batches = [];
      let currentBatch = db.batch();
      let count = 0;
      
      snapshot.docs.forEach(doc => {
        currentBatch.delete(doc.ref);
        count++;
        
        if (count === 500) {
          batches.push(currentBatch);
          currentBatch = db.batch();
          count = 0;
        }
      });
      
      if (count > 0) {
        batches.push(currentBatch);
      }
      
      // Commit all batches
      for (const batch of batches) {
        await batch.commit();
      }
      
      totalDeleted += snapshot.size;
    }
    
    console.log(`Cleanup complete! Deleted ${totalDeleted} guest documents.`);
    return null;
  });

// Optional: Manual trigger via HTTP
exports.manualCleanupGuestData = functions.https.onCall(async (data, context) => {
  // Verify admin
  if (!context.auth || !context.auth.token.admin) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Must be an admin to trigger cleanup'
    );
  }
  
  const olderThanDays = data.olderThanDays || 30;
  // ... same cleanup logic as above ...
  
  return { success: true, message: `Deleted ${totalDeleted} documents` };
});
```

3. Deploy:
```bash
firebase deploy --only functions
```

### Schedule Options

- Every day: `'0 2 * * *'`
- Every week: `'0 2 * * 0'` (Sunday at 2 AM)
- Every month: `'0 2 1 * *'` (1st of month at 2 AM)
- Custom: Use [cron expression](https://crontab.guru/)

## Cost Considerations

### Firestore Pricing (as of 2024)

- **Storage**: $0.18/GB/month
- **Document Reads**: $0.06 per 100,000
- **Document Writes**: $0.18 per 100,000
- **Document Deletes**: $0.02 per 100,000

### Example Cost Savings

If you have 10,000 guest games (average 15KB each):
- Storage: ~150MB = $0.027/month
- Cleanup every 30 days saves: $0.324/year per 10K games

For high-traffic apps with millions of guest games, cleanup can save hundreds of dollars per year.

## Monitoring

### Check Guest Data Size

Add this to your Firebase console or admin panel:

```dart
final cleanupService = GuestCleanupService();
final stats = await cleanupService.getGuestDataStats();

int totalDocuments = 0;
stats.forEach((collection, count) {
  print('$collection: $count documents');
  totalDocuments += count;
});

print('\nTotal guest documents: $totalDocuments');
```

### Firebase Console

1. Go to Firebase Console → Firestore
2. Query for documents where `userId == 'guest'`
3. Monitor document counts over time

## Safety

### Data Isolation

- Guest data: `userId = 'guest'`
- Authenticated data: `userId = Firebase Auth UID`
- Cleanup only affects `userId = 'guest'`
- Authenticated user data is **never touched**

### Testing Before Production

Test cleanup on a staging/dev environment first:

```dart
// 1. Check what would be deleted
final stats = await cleanupService.getGuestDataStats();
print('Would delete: $stats');

// 2. Try a small cleanup first
await cleanupService.deleteOldGuestData(olderThanDays: 365); // 1 year old

// 3. Verify results
final statsAfter = await cleanupService.getGuestDataStats();
print('After cleanup: $statsAfter');

// 4. If safe, proceed with production cleanup
```

## Best Practices

1. **Start Conservative**: Begin with 90-day cleanup, then adjust
2. **Monitor Costs**: Check Firebase billing dashboard regularly
3. **Log Cleanup**: Always log how many documents were deleted
4. **Schedule Wisely**: Run during low-traffic hours (2-4 AM)
5. **Test First**: Always test on staging environment
6. **Gradual Rollout**: Start with weekly cleanup, then increase frequency if needed
7. **Alert on Errors**: Set up error monitoring for cleanup failures

## Troubleshooting

### Cleanup Too Slow

If cleanup takes too long:
- Increase batch size (current: 500, max: 500)
- Run more frequently with shorter retention (e.g., weekly with 7-day retention)
- Use multiple Cloud Functions for different collections

### High Delete Costs

If delete costs are high:
- Increase retention period (delete less frequently)
- Consider TTL (Time To Live) indexes (Firebase feature)
- Optimize write operations to reduce unnecessary documents

### Guest Data Still Growing

If guest data continues to grow despite cleanup:
- Check if cleanup is running successfully
- Verify `updatedAt` timestamps are being set correctly
- Consider shorter retention period
- Review app usage patterns

## Summary

- **Always safe**: Only affects userId='guest'
- **Cost effective**: Reduces storage costs significantly
- **Flexible**: Choose your own retention policy
- **Automated**: Set and forget with Cloud Functions
- **Monitored**: Built-in stats and logging
