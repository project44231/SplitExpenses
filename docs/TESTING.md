# Testing Guide

## 🚀 Quick Start

### Run the App
```bash
flutter run
# Press 'r' for hot reload
# Press 'R' for hot restart
```

Pick your device:
- **iOS**: Tested & working ✅
- **Android**: Tested & working ✅

---

## ✅ What to Test (Full Flow - UPDATED!)

### 1. Guest Mode ✅
**Steps**:
1. App launches → Splash screen (2s)
2. Auth screen appears
3. Click **"Continue as Guest"**
4. **Lands directly on Active Game screen!** (streamlined UX)

**Expected**:
- ✅ No home screen (goes straight to game)
- ✅ Empty state shows "Add First Player"
- ✅ "Add Player" and "Add Buy-In" buttons at bottom

**Test persistence**:
- Close app completely
- Reopen → Should go straight to Active Game (skips auth)

---

### 2. Add Players ✅
**Steps**:
1. Click **"Add Player"** button (bottom left)
2. Enter player name (e.g., John)
3. Click "Add Player" in dialog
4. Repeat for 3-4 players (Sarah, Mike, Lisa)

**Expected**:
- ✅ Players appear immediately as cards
- ✅ Avatar shows first initial
- ✅ Shows "No buy-in" initially
- ✅ Each card has a "+" button
- ✅ Empty state disappears after first player

---

### 3. Quick Buy-In (NEW! ⚡)
**Steps - Method 1 (Quick)**:
1. Click the **"+"** button next to any player card
2. Enter amount (e.g., 100)
3. Click "Add Buy-In"

**Steps - Method 2 (Traditional)**:
1. Click **"Add Buy-In"** button (bottom right)
2. Select player from dropdown
3. Enter amount
4. Click "Add Buy-In"

**Expected**:
- ✅ Using "+": Player is pre-selected (2-click workflow!)
- ✅ Quick amount buttons work ($20, $50, $100, $200)
- ✅ Player card updates with total
- ✅ Buy-in count shows "X buy-ins" (if > 1)
- ✅ Total pot increases
- ✅ Timer starts after first buy-in

**Test multiple buy-ins**:
- Click "+" on player who already has buy-in
- Add another amount
- Count should show "2 buy-ins", "3 buy-ins", etc.
- **Tap on player card** to expand and see all buy-ins with timestamps

**Test edit/delete buy-ins**:
- Expand a player card with buy-ins
- Click **edit icon** (pencil) on any buy-in
- Change the amount, click "Update"
- See success notification
- Click **delete icon** (trash) on a buy-in
- Confirm deletion in dialog
- Buy-in should be removed

**Test player management**:
- Click **menu icon** (⋮) on any player card
- Select "Edit Name"
- Change the name, click "Update"
- Name should update immediately
- Try to remove a player with buy-ins → Should show error
- Delete all buy-ins for a player
- Click menu → "Remove Player"
- Confirm removal
- Player removed from game (but still in player list)

---

### 4. Game Settings ⚙️
**Steps**:
1. Click the **settings icon** (gear) in the top right
2. Settings dialog opens
3. See current quick amounts (default: 20, 50, 100, 200)
4. Try editing an amount (e.g., change 20 to 25)
5. Try adding a new amount (click "Add Another Amount")
6. Try removing an amount (click the red minus icon)
7. Click "Reset to Default" to restore defaults
8. Click "Save Settings"

**Expected**:
- ✅ Settings saved successfully
- ✅ New amounts appear in add/edit buy-in dialogs
- ✅ Amounts auto-sorted in ascending order
- ✅ Need at least 2 amounts (validation)
- ✅ Can't save invalid/empty amounts

### 5. Active Game Tracking ✅
**What to observe**:
- ✅ Live timer (HH:MM:SS format) updates every second
- ✅ Total pot shows sum of all buy-ins
- ✅ Settings button in app bar
- ✅ Player cards show:
  - Name & avatar
  - Total buy-in amount
  - Buy-in count (if > 1)
  - "+" button for quick buy-in
  - **Tap to expand**: Shows all buy-ins with exact time and relative time
  - **Edit/delete icons**: Fix mistakes on any buy-in
- ✅ Pull-to-refresh works

**Test live updates**:
- Add multiple buy-ins
- Watch timer tick
- Watch pot total update
- Check buy-in count

---

### 6. End Game & Settlement ✅
**Steps**:
1. Click **"End Game"** button (top right)
2. Confirm in dialog
3. **Cash-Out Dialog** appears
4. Enter cash-out amounts for each player
   - Try "Break Even" button
   - Try "2x" button
   - Try "Bust" button
5. Click "Calculate Settlement"

**Expected - Cash-Out Entry**:
- ✅ Shows total buy-in at top
- ✅ Real-time total cash-out updates
- ✅ Warning appears if mismatch
- ✅ Quick buttons set amounts instantly
- ✅ Validates non-negative amounts

**Expected - Settlement Screen**:
- ✅ Player results sorted by profit/loss
- ✅ Winners at top (green), losers at bottom (red)
- ✅ Profit/loss with +/- and trending icon
- ✅ Optimized settlement transactions
- ✅ Transaction counter badge
- ✅ "Who owes whom" cards with arrows
- ✅ Share button works
- ✅ "Edit Cash-Outs" reopens dialog
- ✅ "Start New Game" goes back to Active Game

**Test settlement algorithm**:
- 4 players, various wins/losses
- Check transaction count (should be 2-3, not 6!)
- Verify math: sum of transactions = 0

---

### 7. Navigation & Menu ✅
**Steps**:
1. Tap hamburger menu (top left)
2. Check menu options:
   - Game History (placeholder)
   - Profile (placeholder)
   - Sign Out

**Test Sign Out**:
- Click "Sign Out"
- Should return to Auth screen
- Click "Continue as Guest" again
- Should see Active Game with previous data (persisted locally)

---

## 🎯 What Works Now

✅ **Guest Mode**: Login persists  
✅ **Streamlined UX**: Auth → Active Game (no extra screens!)  
✅ **Players**: Add players on the fly  
✅ **Quick Buy-Ins**: "+" button on each player (2-click!)  
✅ **Buy-In Tracking**: Initial + rebuys, live timer, total pot  
✅ **Settlement**: Cash-outs, profit/loss, optimized algorithm  
✅ **Share**: Export settlement summary  
✅ **Navigation**: Hamburger menu with sign out  
✅ **Storage**: Data persists locally (Hive)  
✅ **Zero Errors**: `flutter analyze` passes  

## ❌ What Doesn't Work Yet

- Game history (placeholder)
- Player statistics (placeholder)
- Firebase sync (local only for now)
- Profile screen (placeholder)

---

## 🧪 Full Testing Checklist

### Core Flow
- [ ] Guest login persists
- [ ] Lands on Active Game after auth
- [ ] Can add players
- [ ] Can add buy-ins (both methods)
- [ ] "+" button pre-selects player
- [ ] Timer starts after first buy-in
- [ ] Total pot updates correctly
- [ ] Rebuy count increments
- [ ] Can end game
- [ ] Cash-out validation works
- [ ] Settlement math is correct
- [ ] Share button works
- [ ] Can start new game after settlement
- [ ] Sign out returns to auth

### Edge Cases
- [ ] Empty state (no players)
- [ ] Single player
- [ ] All players bust (0 cash-out)
- [ ] Mismatch warning appears
- [ ] Multiple buy-ins per player
- [ ] Large amounts (1000+)
- [ ] Decimal amounts (50.50)
- [ ] Edit buy-in to $0 (should validate)
- [ ] Delete all buy-ins for a player
- [ ] Edit immediately after adding

---

## 📱 Platform Testing

### iOS ✅
```bash
flutter run  # Select iOS simulator
```
- Tested & working
- Smooth performance

### Android ✅
```bash
flutter run  # Select Android emulator
```
- Tested & working
- NDK version fixed
- Hot reload works

---

## 🚀 Next Features to Build

1. **Game History** - View past games (3-4 hrs)
2. **Player Stats** - ROI, win rate, leaderboards (3-4 hrs)
3. **Firebase Integration** - Cloud sync (optional, 4-5 hrs)

---

**Status**: 88% to MVP complete! 🎉  
**Last Updated**: Feb 7, 2026
