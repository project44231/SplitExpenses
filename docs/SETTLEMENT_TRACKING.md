# Settlement Tracking Implementation

## Overview
Settlement transactions are now automatically saved to Firestore for historical tracking purposes. This allows you to view past settlements and analyze payment history over time.

## Data Storage

### Firestore Collection: `settlements`
Each settlement document contains:
```json
{
  "id": "unique-settlement-id",
  "gameId": "game-id",
  "transactions": [
    {
      "fromPlayerId": "player-id",
      "toPlayerId": "player-id",
      "amount": 150.00
    }
  ],
  "generatedAt": "2026-02-09T12:00:00Z",
  "userId": "user-id-or-guest"
}
```

## How It Works

### Automatic Saving
When you enter or update cash-outs on the settlement screen:
1. Settlement transactions are calculated using the optimized debt simplification algorithm
2. Transactions are automatically saved to Firestore in the background
3. Each calculation creates a new settlement record with timestamp
4. No user action required - it happens automatically

### Data Flow
```
Cash-Outs Entered
    ↓
Settlement Calculated
    ↓
Transactions Generated
    ↓
Saved to Firestore (settlements collection)
    ↓
Available for Historical Analysis
```

## API Methods

### Save Settlement
```dart
// Automatically called by settlement screen
await ref.read(gameProvider.notifier).saveSettlement(
  gameId: gameId,
  transactions: transactions,
);
```

### Get All Settlements for a Game
```dart
final settlements = await ref.read(gameProvider.notifier).getSettlements(gameId);
```

### Get Latest Settlement (via FirestoreService)
```dart
final latestSettlement = await firestoreService.getLatestSettlement(gameId);
```

## Security Rules
Settlements follow the same security pattern as other game data:
- **Read**: User owns the game OR game is guest-owned
- **Create**: Authenticated users OR guest mode
- **Update/Delete**: User owns the game

## Use Cases

### 1. Historical Analysis
Track how settlements change over time if cash-outs are edited or recalculated.

### 2. Dispute Resolution
Reference past settlements to resolve payment disputes.

### 3. Pattern Recognition
Analyze payment patterns across multiple games.

### 4. Audit Trail
Maintain a complete history of all settlement calculations.

## Future Enhancements

Potential features to add:

1. **Settlement History Screen**
   - View all past settlements for a game
   - Compare different settlement calculations
   - Show timeline of settlements

2. **Payment Status Tracking**
   - Mark transactions as paid/unpaid
   - Track partial payments
   - Send payment reminders

3. **Analytics**
   - Most frequent payers/receivers
   - Average settlement amounts
   - Payment velocity metrics

4. **Export Options**
   - Export settlement history to CSV
   - Generate PDF reports
   - Email settlement summaries

## Implementation Files

- **Model**: `lib/models/settlement.dart`
- **Service**: `lib/services/firestore_service.dart` (lines 244-276)
- **Provider**: `lib/features/game/providers/game_provider.dart` (lines 376-399)
- **Screen**: `lib/features/game/screens/settlement_screen.dart` (lines 171-182)
- **Security**: `firestore.rules` (lines 89-99)

## Testing

To verify settlement tracking is working:

1. Create a game with players
2. Add buy-ins for all players
3. Navigate to settlement screen
4. Enter cash-outs
5. Check Firestore console for new document in `settlements` collection

## Notes

- Settlements are saved in the background (non-blocking)
- If saving fails, it won't affect the user experience (error is logged only)
- Each cash-out update creates a new settlement record (keeps full history)
- Local storage is NOT used for settlements (Firestore only for tracking)
