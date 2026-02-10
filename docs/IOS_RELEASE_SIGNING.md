# iOS Release Signing & Deployment Setup

This guide walks you through setting up code signing for iOS App Store distribution.

## Prerequisites

- Mac with Xcode 16.0+ installed ✓ (you have Xcode 16.0)
- Apple ID (free, for development)
- **Apple Developer Program membership ($99/year, required for App Store)**

## Step 1: Enroll in Apple Developer Program

1. Go to [Apple Developer Program](https://developer.apple.com/programs/)
2. Click "Enroll" and sign in with your Apple ID
3. Complete enrollment ($99/year)
4. Wait for approval (usually 24-48 hours)

**Note:** You cannot upload to App Store without this membership.

## Step 2: Sign In to Xcode

1. Open Xcode
2. Go to **Xcode → Settings** (or Preferences)
3. Click the **Accounts** tab
4. Click **+** button at bottom left
5. Select **Apple ID** and sign in
6. Your Apple Developer account should appear

## Step 3: Configure Signing in Xcode

### Open the Project

```bash
cd /Users/hanish/Documents/Projects/AI_PROJECTS/gametracker
open ios/Runner.xcworkspace
```

**Important:** Always open `.xcworkspace`, NOT `.xcodeproj` (for CocoaPods compatibility)

### Set Up Signing

1. In Xcode, select **Runner** in the project navigator (left sidebar)
2. Select the **Runner** target under TARGETS
3. Go to **Signing & Capabilities** tab
4. Under **Signing (Debug)** and **Signing (Release)**:
   - Check ✓ **Automatically manage signing**
   - Select your **Team** from the dropdown (should show your Apple Developer account)
   - Verify **Bundle Identifier**: `com.gametracker.pokerTracker`

Xcode will automatically:
- Create App ID in Developer Portal
- Generate provisioning profiles
- Handle certificate management

### If You See Errors

**"Failed to create provisioning profile"**
- Ensure you're enrolled in Apple Developer Program (not just free account)
- Check that your account is in good standing
- Try manual signing if automatic fails (see Advanced section)

**"Bundle identifier is unavailable"**
- Someone else registered this ID, choose a unique one
- Update in both Xcode and `Info.plist`

## Step 4: Register App ID in Developer Portal

1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Click **Identifiers** → **+** button
4. Select **App IDs** → **App**
5. Configure:
   - **Description**: Poker Tracker
   - **Bundle ID**: `com.gametracker.pokerTracker` (Explicit)
   - **Capabilities**: Enable if needed:
     - Sign in with Apple (if using Apple Sign-In)
     - Push Notifications (if using)

6. Click **Continue** → **Register**

## Step 5: Test Build

From terminal:

```bash
# Clean build folder
flutter clean

# Get dependencies
flutter pub get

# Build for iOS (creates .app in simulator)
flutter build ios --release --no-codesign

# Or build IPA for real device/distribution
flutter build ipa --release
```

**Expected output:**
```
✓ Built ios/Runner.app
```

If building IPA and you see signing issues, ensure Xcode configuration is correct.

## Step 6: Archive for App Store

### Using Xcode (Recommended)

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Any iOS Device (arm64)** as destination (not simulator)
3. Go to **Product → Archive**
4. Wait for archive to complete
5. Xcode Organizer will open automatically
6. Select your archive → Click **Distribute App**
7. Choose **App Store Connect**
8. Follow the wizard

### Using Command Line

```bash
flutter build ipa --release
```

The IPA will be at: `build/ios/ipa/poker_tracker.ipa`

Upload via Xcode or Application Loader.

## Step 7: App Store Connect Setup

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Click **My Apps** → **+** → **New App**
3. Fill in:
   - **Platforms**: iOS
   - **Name**: Poker Tracker
   - **Primary Language**: English (U.S.)
   - **Bundle ID**: Select `com.gametracker.pokerTracker`
   - **SKU**: pokertracker (or any unique identifier)
   - **User Access**: Full Access

4. Configure app information:
   - **Category**: Entertainment or Games
   - **Age Rating**: Complete questionnaire (likely 12+ for gambling theme)
   - **Privacy Policy URL**: [Your hosted privacy policy URL]
   - **App Description**: [Your marketing description]
   - **Keywords**: poker, tracker, home game, buy-in, settlement
   - **Screenshots**: Upload for required device sizes
   - **App Icon**: Already configured in project

## Important iOS Requirements

### Privacy Manifest (iOS 17+)

Your app needs privacy declarations for:
- Camera usage ✓ (already added)
- Photo library access ✓ (already added)
- Network usage (Firebase)

### Required URLs

Set these up before submission:
- **Privacy Policy URL**: Required for App Store listing
- **Support URL**: Where users can get help
- **Marketing URL**: (Optional) Your app's website

### App Store Review

Be prepared to explain:
- **Purpose**: Home poker game tracking, not real money gambling
- **Target Audience**: Friends hosting home games
- **Key Features**: Buy-in tracking, settlement calculation

## Advanced: Manual Signing

If automatic signing fails, use manual mode:

1. In Xcode Signing & Capabilities:
   - Uncheck "Automatically manage signing"
   - **Provisioning Profile**: Select manually created profile
   - **Signing Certificate**: Select your distribution certificate

2. Create certificates/profiles in Developer Portal:
   - **Development Certificate** (for testing)
   - **Distribution Certificate** (for App Store)
   - **Provisioning Profiles** for each

## Troubleshooting

### "No signing certificate found"

```bash
# Check installed certificates
security find-identity -v -p codesigning
```

Solution: Let Xcode create automatically or create manually in Developer Portal.

### "Provisioning profile doesn't match"

- Bundle ID in Xcode must exactly match provisioning profile
- Check: `com.gametracker.pokerTracker` everywhere

### "Failed to verify bitcode"

Add to `ios/Runner/Info.plist`:
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

(Already handles standard encryption, no export compliance needed)

### Build fails with CocoaPods error

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

## Security Best Practices

- [ ] Never commit provisioning profiles to Git
- [ ] Use Automatic signing for easier management
- [ ] Keep Xcode and CocoaPods updated
- [ ] Test on real device before submission
- [ ] Enable App Store Connect Two-Factor Authentication

## Pre-Submission Checklist

- [ ] Apple Developer Program membership active
- [ ] Team configured in Xcode
- [ ] App builds successfully with release configuration
- [ ] Privacy permissions descriptions added ✓
- [ ] App tested on physical iOS device
- [ ] Privacy Policy URL ready
- [ ] Screenshots captured (multiple device sizes)
- [ ] App Store listing completed
- [ ] Age rating set appropriately

## Resources

- [Apple Developer Portal](https://developer.apple.com/account/)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)

## Support

If you encounter issues:
1. Check [Flutter iOS deployment guide](https://docs.flutter.dev/deployment/ios)
2. Review Apple Developer Forums
3. Contact Apple Developer Support (requires membership)
