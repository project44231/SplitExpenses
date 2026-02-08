# Game Flow Documentation

## Complete Game Lifecycle

### 1. Start Game (Active Game Screen)

**Entry Point**: Home Screen → Start Game OR automatically created

**Actions:**
- Add players (search existing or create new)
- Add buy-ins (quick buttons or custom amount)
- Edit/delete buy-ins
- Edit player names
- Remove players (only if 0 buy-ins)
- Customize quick buy-in amounts (Settings)
- View real-time totals and pot

**Status**: Game status = `active`

---

### 2. End Game Button → Cash-Out Screen

**Trigger**: Click "End Game" button in Active Game

**Important**: Game does NOT end yet! Status stays `active`.

**Why**: Allows users to:
- Go back to active game to verify buy-in totals
- Make corrections to buy-ins if needed
- Review player standings before finalizing

**Actions on Cash-Out Screen:**
- Enter cash-out amount for each player
- See total buy-in vs total cash-out
- Warning if amounts mismatch
- **Back button** → Returns to Active Game (game still active)
- **Calculate Settlement button** → Proceeds to step 3

---

### 3. Calculate Settlement → Settlement Screen

**Trigger**: Click "Calculate Settlement" button in Cash-Out Screen

**This is when the game ACTUALLY ends!**

**What Happens:**
1. Cash-outs are saved to Firestore
2. Game status changes to `ended`
3. Game `endTime` is set
4. Settlement algorithm runs (minimize transactions)
5. Navigate to Settlement Screen

**Actions on Settlement Screen:**
- View optimized payment transfers
- See profit/loss for each player
- **Back to Game button** → View ended game (read-only)
- **Start New Game button** → Create fresh game

---

## Flow Diagram

```
┌─────────────────┐
│  Active Game    │ ← Can edit buy-ins, add/remove players
│  (status=active)│
└────────┬────────┘
         │
         │ Click "End Game"
         ↓
┌─────────────────┐
│  Cash-Out       │ ← Enter cash-out amounts
│  (status=active)│ ← Can go BACK to Active Game
└────────┬────────┘
         │
         │ Click "Calculate Settlement"
         ↓
    [Game Ends]  ← Status changes to 'ended'
         ↓
┌─────────────────┐
│  Settlement     │ ← View optimized transfers
│  (status=ended) │ ← Read-only
└────────┬────────┘
         │
         ├─→ Back to Game (view ended game)
         └─→ Start New Game (create new active game)
```

---

## Key Design Decisions

### Why Game Stays Active Until Cash-Outs?

**Problem**: Users might realize they entered a wrong buy-in amount after clicking "End Game"

**Solution**: 
- Game stays active during cash-out entry
- Back button allows returning to active game
- Can fix buy-ins, then go back to cash-out
- Game only ends when cash-outs are final

**Benefits**:
- Prevents data loss
- Allows corrections before finalizing
- More forgiving UX
- Reduces errors in settlement

### Why Not Just Go Back to Edit Cash-Outs?

Once the game ends and settlement is calculated:
- Settlement transactions are already computed
- Going back to edit would require re-calculating everything
- Players might have already started settling payments
- Cleaner to allow fixing buy-ins BEFORE finalizing

---

## Navigation Paths

### From Active Game Screen
- `/game/{gameId}` (active game)
- → `/cash-out/{gameId}` (click End Game button)
- → `/game` (drawer menu → New Game)
- → `/history` (drawer menu)

### From Cash-Out Screen
- `/cash-out/{gameId}`
- → `/game/{gameId}` (back button - game stays active)
- → `/settlement/{gameId}` (Calculate Settlement - game ends)

### From Settlement Screen
- `/settlement/{gameId}`
- → `/game/{gameId}` (Back to Game - view ended game)
- → `/game` (Start New Game - create new active game)

---

## Error Handling

### During Buy-In Entry
- Validates positive numbers only
- Shows error for invalid input
- Can edit/delete any buy-in

### During Cash-Out Entry
- Validates positive numbers only
- Shows warning if total mismatch (buy-in ≠ cash-out)
- Allows proceeding even with mismatch (real-world: cash might be missing/extra)
- Back button available anytime

### During Settlement
- Shows "No data" if game not found
- Error screen with retry option
- Can always go back to view game

---

## Firebase Data Changes

### Active Game → Cash-Out Screen
- **No database changes**
- Game status: `active`
- Just navigation

### Cash-Out Screen → Settlement Screen
- **Cash-outs saved** to `cash_outs` collection
- **Game status updated** to `ended`
- **endTime set** to current timestamp
- **Settlements calculated** and saved to `settlements` collection

---

## Summary

**Old Flow** (confusing):
Active → End (game ends) → Cash-Out → Settlement

**New Flow** (better UX):
Active → Cash-Out (can go back) → Submit (game ends) → Settlement

This gives users flexibility to fix mistakes before finalizing!
