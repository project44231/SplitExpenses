# Testing Guide

## 🚀 Quick Start

### Run the App
```bash
flutter run
```

Pick your device:
- **iOS**: Already tested & working ✅
- **Android**: Build in progress (first time ~10 min)

---

## ✅ What to Test

### 1. Guest Mode (Working)
**Steps**:
1. App launches → Splash screen (2s)
2. Auth screen appears
3. Click **"Continue as Guest"**
4. Home screen loads

**Expected**:
- ✅ Navigates to home
- ✅ Bottom nav visible (4 tabs)
- ✅ "New Game" button visible

**Test persistence**:
- Close app completely
- Reopen → Should go straight to Home (skips auth)

---

### 2. New Game Screen (Working)
**Steps**:
1. Tap green **"New Game"** FAB button
2. Click **"Add"** to create players
3. Add 3-4 players (e.g., John, Sarah, Mike, Lisa)
4. **Select players** with checkboxes
5. Try **search bar** - type a name
6. Change **currency** (dropdown)
7. Add optional **notes**
8. Click **"Start Game"**

**Expected**:
- ✅ Players save permanently
- ✅ Search filters instantly
- ✅ Selected count updates
- ✅ Can't start with 0 players
- ✅ Navigates to Active Game screen

**Test persistence**:
- Go back, add more players
- They should still be there!

---

### 3. Active Game Screen (Placeholder)
**Current**: Shows "Coming Soon"  
**Next to build**: Buy-in tracking

---

## 🐛 Known Issues

### Android Build Warnings
- SDK XML version warnings → Ignore (cosmetic)
- Kotlin compatibility → Fixed, should work now

### iOS Simulator Only
- Android emulator had issues
- Not critical - iOS works fine for testing

---

## 🎯 What Works

✅ **Guest Mode**: Login persists  
✅ **Players**: Add, search, select  
✅ **Games**: Create games  
✅ **Navigation**: All tabs/screens  
✅ **Storage**: Data persists locally  

## ❌ What Doesn't Work Yet

- Active game tracking (placeholder)
- Buy-ins (not implemented)
- Settlements (not implemented)
- History (empty)
- Statistics (zeros)

---

## 🧪 Testing Checklist

- [ ] App launches without crashes
- [ ] Guest mode login works
- [ ] Data persists after restart
- [ ] Can add players
- [ ] Can search players
- [ ] Can create games
- [ ] Navigation works
- [ ] UI looks good

---

## 📱 Recommended: Test on iOS

Since iOS is already working:
1. Find the terminal with `flutter run` for iOS
2. Press `R` to hot restart
3. Test everything above
4. Much faster than waiting for Android!

---

## 🚀 Next Features to Build

1. **Active Game** - Track buy-ins (4-5 hrs)
2. **Settlement** - Calculate results (3 hrs)
3. **History** - View past games (3 hrs)

---

**Ready to test!** Use iOS for now - it's faster. 🎮
