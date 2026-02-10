# Screenshot Capture Guide for App Stores

This guide helps you capture high-quality screenshots for Google Play Store and Apple App Store submissions.

---

## Required Screenshots

### Google Play Store

**Minimum Requirements:**
- At least **2 screenshots** (maximum 8)
- **Phone portraits**: 1080 x 1920 px or 1080 x 2340 px
- Format: PNG or JPEG (PNG recommended)
- No alpha transparency

**Feature Graphic (Required):**
- 1024 x 500 px
- PNG or JPEG format
- Will be displayed at the top of your store listing

### Apple App Store

**Minimum Requirements:**
- At least **3 screenshots** per device size (maximum 10)
- Required sizes:
  - **6.7" Display** (iPhone 14 Pro Max): 1290 x 2796 px
  - **6.5" Display** (iPhone 11 Pro Max): 1284 x 2778 px
  - **5.5" Display** (iPhone 8 Plus): 1242 x 2208 px
- Format: PNG or JPEG (PNG recommended)

**Optional but Recommended:**
- iPad screenshots: 2048 x 2732 px (12.9") or 1668 x 2388 px (11")

---

## Suggested Screenshot Flow

Capture screenshots showing the app's core journey:

### 1. Active Game Screen - Players List
**Shows:** Player cards with buy-ins, quick add buttons, timer
**Key Elements:** Active game in progress with 3-4 players

### 2. Add Buy-In Dialog
**Shows:** Quick amount buttons, custom input, player selection
**Key Elements:** User-friendly buy-in entry

### 3. Expanded Player Card
**Shows:** Detailed transaction history with timestamps
**Key Elements:** Professional transaction tracking

### 4. Settlement Screen
**Shows:** Cash-out entry, profit/loss, optimized transactions
**Key Elements:** Smart settlement calculations

### 5. Game History
**Shows:** List of past games with filters
**Key Elements:** Complete game archive

### 6. Player Statistics / Leaderboard
**Shows:** Player performance stats
**Key Elements:** Comprehensive statistics

### 7. Settings / Quick Amounts
**Shows:** Customizable quick buy-in amounts
**Key Elements:** Flexibility for different stakes

### 8. Live Sharing (Optional)
**Shows:** Web viewer or share functionality
**Key Elements:** Collaboration features

---

## Methods to Capture Screenshots

### Method 1: Android Emulator (Easiest)

#### Setup

1. Open Android Studio or run from command line:
```bash
flutter emulators
flutter emulators --launch <emulator-id>
```

2. Select the desired resolution:
   - Pixel 6 (1080 x 2340) - Recommended
   - Pixel 7 Pro (1440 x 3120) - High resolution

3. Run your app:
```bash
flutter run
```

#### Capture

**Option A: Android Studio Screenshot Tool**
1. With emulator running, click the **camera icon** in the emulator toolbar
2. Screenshot saves automatically to your Pictures folder
3. Already at correct resolution

**Option B: Command Line (via ADB)**
```bash
adb exec-out screencap -p > screenshot.png
```

**Option C: Emulator UI**
- Press `Ctrl + S` (Windows/Linux) or `Cmd + S` (Mac)

#### Resize if Needed

If your emulator doesn't match required size exactly:
```bash
# Install ImageMagick if you don't have it
brew install imagemagick

# Resize to Google Play requirements
convert input.png -resize 1080x2340\! output.png
```

### Method 2: iOS Simulator (Mac Only)

#### Setup

1. Launch simulator:
```bash
open -a Simulator
```

2. Select device:
   - **Hardware → Device → iPhone 14 Pro Max** (6.7" - 1290 x 2796)
   - **Hardware → Device → iPhone 11 Pro Max** (6.5" - 1284 x 2778)
   - **Hardware → Device → iPhone 8 Plus** (5.5" - 1242 x 2208)

3. Run your app:
```bash
flutter run -d <simulator-id>
```

#### Capture

**Option A: Simulator Screenshot**
1. With simulator running, press `Cmd + S`
2. Screenshot saves to Desktop
3. Already at correct resolution for App Store

**Option B: Command Line**
```bash
xcrun simctl io booted screenshot screenshot.png
```

**Option C: Screenshot via Xcode**
1. In Xcode, open your project
2. Run on simulator
3. Debug → Capture View Hierarchy → Export screenshot

### Method 3: Physical Device (Recommended for Best Quality)

#### Android

1. Enable Developer Options on your device:
   - Settings → About Phone → Tap "Build Number" 7 times
   - Settings → Developer Options → Enable USB Debugging

2. Connect device via USB

3. Run app:
```bash
flutter run
```

4. Capture screenshot:
   - **On device**: Power + Volume Down buttons simultaneously
   - **Via ADB**: `adb exec-out screencap -p > screenshot.png`

5. Transfer to computer and resize if needed

#### iOS

1. Connect iPhone via USB

2. Run app:
```bash
flutter run
```

3. Capture screenshot:
   - **iPhone with Face ID**: Side button + Volume Up
   - **iPhone with Home button**: Power + Home button

4. Transfer via AirDrop or Photos app to Mac

5. Screenshots are automatically at correct resolution

---

## Screenshot Preparation Tips

### 1. Prepare Demo Data

Before capturing, set up realistic demo data:

```dart
// Create sample game with players
- Game name: "Friday Night Poker"
- Date: Recent date
- Players: 4-5 players with realistic names
- Buy-ins: Various amounts ($20, $50, $100)
- Timer: Show active game (e.g., "1h 23m")
```

### 2. Use Light Mode

Most users prefer to see screenshots in light mode for store listings (higher visibility).

### 3. Remove Status Bar Distractions

Consider using a clean status bar:
- Full battery
- Good signal
- Clean time (e.g., 9:41 AM - Apple's classic time)

**Tools to edit status bars:**
- [StatusBuddy](https://statusbuddy.app/) (Mac)
- [CleanStatusBar](https://github.com/shinydevelopment/SimulatorStatusMagic) (iOS Simulator)

### 4. Consistent Device Frame (Optional)

Add device frames for a professional look:

**Tools:**
- [Device Frames](https://deviceframes.com/)
- [MockUPhone](https://mockuphone.com/)
- [Figma](https://www.figma.com/) with device frame templates

### 5. Add Text Overlays (Optional)

Some developers add text descriptions to screenshots:
- Feature highlights
- Benefits
- Call-to-action

**Tools:**
- [Figma](https://www.figma.com/)
- [Canva](https://www.canva.com/)
- [Sketch](https://www.sketch.com/)
- [Adobe Photoshop](https://www.adobe.com/products/photoshop.html)

---

## Quick Capture Workflow

### Step-by-Step

1. **Launch emulator/simulator** with correct device size
2. **Run your app**: `flutter run`
3. **Navigate to first screen** (e.g., Active Game)
4. **Set up demo data** if needed
5. **Capture screenshot**: `Cmd+S` or screenshot button
6. **Repeat** for each required screen
7. **Organize** screenshots in a folder with descriptive names
8. **Optimize** images (compress, add frames, add text)

### Naming Convention

Use descriptive filenames:
```
01_active_game_players.png
02_add_buyin_dialog.png
03_player_transactions.png
04_settlement_screen.png
05_game_history.png
06_player_stats.png
07_settings_amounts.png
08_live_sharing.png
```

---

## Image Optimization

### Compress Images

Reduce file size without losing quality:

**Online Tools:**
- [TinyPNG](https://tinypng.com/) - PNG compression
- [Squoosh](https://squoosh.app/) - Google's image compressor
- [ImageOptim](https://imageoptim.com/) - Mac app

**Command Line:**
```bash
# Install pngquant
brew install pngquant

# Compress PNG
pngquant --quality=80-95 input.png -o output.png
```

### Resize if Needed

```bash
# Using ImageMagick
convert input.png -resize 1080x2340\! output.png

# Using sips (Mac built-in)
sips -z 2340 1080 input.png --out output.png
```

---

## Creating Feature Graphic (Android Only)

**Size**: 1024 x 500 px

### Design Elements

Include:
- App icon
- App name: "Game buy-in tracker"
- Tagline: "Track. Settle. Play." or "Home Poker Games Made Simple"
- Background: Use app colors (#1E88E5 blue)
- Optional: Screenshots or mockups

### Design Tools

**Quick Options:**
- [Canva](https://www.canva.com/) - Templates available
- [Figma](https://www.figma.com/) - Free design tool
- [Photopea](https://www.photopea.com/) - Free Photoshop alternative

**Professional Options:**
- Adobe Photoshop
- Adobe Illustrator
- Sketch (Mac)

### Template Idea

```
[App Icon]  POKER TRACKER
            Track. Settle. Play.
            
[Screenshot preview on right side]
```

Background: Gradient from blue (#1E88E5) to darker blue

---

## Screenshot Review Checklist

Before uploading, verify:

- [ ] Correct dimensions for target platform
- [ ] No personal/sensitive information visible
- [ ] Demo data looks realistic and professional
- [ ] UI is clean (no debug info, status bars clean)
- [ ] Images are in focus and high quality
- [ ] Consistent styling across all screenshots
- [ ] Shows key features prominently
- [ ] File size is reasonable (< 5MB each)
- [ ] File format is PNG or JPEG
- [ ] Filenames are organized and descriptive

---

## Store-Specific Requirements

### Google Play Console Upload

1. Go to **Store Presence → Main store listing**
2. Scroll to **Phone screenshots**
3. Click **+ Add phones screenshots**
4. Upload 2-8 images
5. Drag to reorder (first image is most important)

**Feature Graphic:**
1. Scroll to **Graphic assets**
2. Upload 1024 x 500 px feature graphic

### App Store Connect Upload

1. Go to **App Store → [Version] → App Store Screenshots**
2. Select device size (e.g., 6.7" Display)
3. Drag and drop screenshots (3-10 images)
4. Reorder as needed
5. Repeat for each device size

**App Previews (Optional):**
- Can also upload video previews (15-30 seconds)
- Requires additional work but increases conversion

---

## Advanced: Automated Screenshot Generation

For consistent, automated screenshots:

### Using Flutter Driver

```dart
// test_driver/app_screenshot_test.dart
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  FlutterDriver driver;
  
  setUpAll(() async {
    driver = await FlutterDriver.connect();
  });
  
  tearDownAll(() async {
    if (driver != null) {
      driver.close();
    }
  });
  
  test('Capture active game screen', () async {
    await driver.waitFor(find.text('Active Game'));
    await driver.screenshot('01_active_game');
  });
}
```

### Using Fastlane Snapshot (iOS)

```ruby
# Fastfile
snapshot(
  scheme: "Runner",
  devices: [
    "iPhone 14 Pro Max",
    "iPhone 11 Pro Max"
  ]
)
```

---

## Need Help?

- **Device not available?** Use emulator/simulator with closest size
- **Wrong resolution?** Resize with ImageMagick or online tools
- **Quality issues?** Capture from physical device when possible
- **Design help?** Consider hiring designer on Fiverr or Upwork

---

## Resources

- [Google Play Screenshot Guidelines](https://support.google.com/googleplay/android-developer/answer/9866151)
- [App Store Screenshot Specifications](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications)
- [Material Design Screenshots](https://material.io/design/communication/imagery.html)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

**Ready to capture? Start with the Active Game screen and work through the flow! 📸**
