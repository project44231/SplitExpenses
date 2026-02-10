# Google Sign-In Setup Guide

Complete step-by-step guide to configure Google authentication for your Game buy-in tracker app.

## Table of Contents

1. [Firebase Console Setup](#firebase-console-setup)
2. [iOS Configuration](#ios-configuration)
3. [Android Configuration](#android-configuration)
4. [Testing](#testing)
5. [Troubleshooting](#troubleshooting)

---

## Firebase Console Setup

### Step 1: Enable Google Sign-In in Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (`gametracker` or your project name)
3. In the left sidebar, click **Authentication**
4. Click on the **Sign-in method** tab
5. Find **Google** in the list of providers
6. Click on **Google**
7. Toggle **Enable** to ON
8. Set **Project support email** (required) - use your email
9. Click **Save**

✅ Google Sign-In is now enabled in Firebase!

---

## iOS Configuration

### Step 1: Get iOS OAuth Client ID

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Scroll down to **Your apps** section
3. Find your iOS app (or add one if not present)
4. Note down the **iOS URL Scheme** (format: `com.googleusercontent.apps.XXXXXXXX`)

### Step 2: Configure Info.plist

Location: `ios/Runner/Info.plist`

Add the following inside the `<dict>` tag:

```xml
<!-- Google Sign-In iOS Configuration -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Replace with your REVERSED_CLIENT_ID from GoogleService-Info.plist -->
      <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

**How to find your REVERSED_CLIENT_ID:**

1. Open `ios/Runner/GoogleService-Info.plist`
2. Find the key `REVERSED_CLIENT_ID`
3. Copy its value (looks like `com.googleusercontent.apps.123456789-abc123def456`)
4. Paste it in the CFBundleURLSchemes array above

### Step 3: Update iOS Bundle Identifier

1. In Firebase Console, go to **Project Settings** → **Your apps** → iOS app
2. Make sure the **Bundle ID** matches your Xcode project
   - In Xcode: Open `ios/Runner.xcworkspace`
   - Select **Runner** project → **Signing & Capabilities**
   - Check **Bundle Identifier** (e.g., `com.yourcompany.gametracker`)
3. If they don't match, either:
   - Update Firebase Console to match Xcode, OR
   - Update Xcode to match Firebase Console

### Step 4: Download GoogleService-Info.plist

1. In Firebase Console, **Project Settings** → **Your apps** → iOS
2. Download **GoogleService-Info.plist**
3. Replace the existing file at `ios/Runner/GoogleService-Info.plist`
4. In Xcode, verify the file is in the **Runner** target

---

## Android Configuration

### Step 1: Get Android OAuth Client ID

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Scroll to **Your apps** → Android app
3. Note the **Package name** (e.g., `com.yourcompany.gametracker`)

### Step 2: Get SHA-1 Certificate Fingerprint

Open terminal and run:

#### For Debug (Development)

```bash
cd android
./gradlew signingReport
```

Look for the **SHA-1** under **Variant: debug**. It looks like:
```
SHA1: A1:B2:C3:D4:E5:F6:...
```

Copy this SHA-1 fingerprint.

#### For Release (Production)

If you have a keystore for release builds:

```bash
keytool -list -v -keystore ~/path/to/your/keystore.jks -alias your_alias
```

Enter your keystore password and copy the SHA-1.

### Step 3: Add SHA-1 to Firebase

1. In Firebase Console, **Project Settings** → **Your apps** → Android
2. Scroll down to **SHA certificate fingerprints**
3. Click **Add fingerprint**
4. Paste your **Debug SHA-1** (and Release SHA-1 if you have it)
5. Click **Save**

### Step 4: Download google-services.json

1. In Firebase Console, **Project Settings** → **Your apps** → Android
2. Download **google-services.json**
3. Replace the file at `android/app/google-services.json`

### Step 5: Update build.gradle files

#### android/build.gradle

Make sure you have the Google services plugin:

```gradle
buildscript {
    dependencies {
        // ... other dependencies
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

#### android/app/build.gradle

At the **bottom** of the file, add:

```gradle
apply plugin: 'com.google.gms.google-services'
```

Also verify your `minSdkVersion` is at least 21:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Must be 21 or higher
        // ... rest of config
    }
}
```

### Step 6: Update AndroidManifest.xml

Location: `android/app/src/main/AndroidManifest.xml`

Add internet permission (if not already present):

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <application>
        <!-- Your existing config -->
    </application>
</manifest>
```

---

## Install Dependencies

After all configuration, install the new dependencies:

```bash
# Get dependencies
flutter pub get

# For iOS, install pods
cd ios
pod install
cd ..

# Clean build
flutter clean
flutter pub get
```

---

## Testing

### Test on iOS Simulator/Device

```bash
flutter run -d ios
```

**Steps:**
1. App opens → Auth screen
2. Tap **"Sign in with Google"**
3. Google account picker appears
4. Select an account
5. App navigates to home/game screen
6. Check Firebase Console → Authentication → Users to see the new user

### Test on Android Emulator/Device

```bash
flutter run -d android
```

**Steps:**
1. Make sure Google Play Services is installed on emulator
2. Follow same steps as iOS testing

### Common Issues During Testing

#### iOS: "The app's Info.plist must contain a CFBundleURLTypes"
- **Fix**: Double-check your `Info.plist` has the correct `REVERSED_CLIENT_ID`

#### Android: "PlatformException: sign_in_failed"
- **Fix**: Make sure SHA-1 fingerprint is added to Firebase Console

#### "User cancelled sign-in"
- This is normal when user dismisses the Google account picker

---

## Troubleshooting

### Error: "API key not valid"

**Cause**: API restrictions in Google Cloud Console

**Fix:**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Go to **APIs & Services** → **Credentials**
4. Find your **OAuth 2.0 Client IDs**
5. For each client (iOS and Android):
   - Remove any unnecessary restrictions
   - OR add restrictions for specific APIs (Firebase Authentication, etc.)

### Error: "account-exists-with-different-credential"

**Cause**: User already signed up with email/Apple, now trying Google

**Fix:**
- User needs to sign in with original method first
- Or, implement account linking in your app (advanced)

### Error: "developer-error"

**Cause**: OAuth client ID mismatch

**Fix for iOS:**
1. Check `REVERSED_CLIENT_ID` in `Info.plist` matches `GoogleService-Info.plist`
2. Clean build: `flutter clean && cd ios && pod install`

**Fix for Android:**
1. Verify SHA-1 in Firebase matches the one from `./gradlew signingReport`
2. Re-download `google-services.json` after adding SHA-1

### Google Sign-In button not responding

**Check:**
1. Internet connection
2. Firebase initialized in `main.dart`
3. Google Sign-In enabled in Firebase Console
4. Dependencies installed: `flutter pub get`

### iOS: "No valid code signing"

**Fix:**
1. Open Xcode: `open ios/Runner.xcworkspace`
2. Select **Runner** → **Signing & Capabilities**
3. Choose a **Team**
4. Xcode will auto-fix provisioning profile

### Android: Build fails with "Duplicate class"

**Fix:**
Add to `android/app/build.gradle`:

```gradle
android {
    // ...
    packagingOptions {
        exclude 'META-INF/DEPENDENCIES'
    }
}
```

### Still not working?

1. Check logs:
   ```bash
   flutter run --verbose
   ```

2. Verify all steps:
   - [ ] Google Sign-In enabled in Firebase Console
   - [ ] `google_sign_in` package in `pubspec.yaml`
   - [ ] iOS: `Info.plist` configured with `REVERSED_CLIENT_ID`
   - [ ] Android: SHA-1 added to Firebase
   - [ ] `google-services.json` / `GoogleService-Info.plist` are latest
   - [ ] Pods installed (`cd ios && pod install`)

3. Clean and rebuild:
   ```bash
   flutter clean
   flutter pub get
   cd ios && pod install && cd ..
   flutter run
   ```

---

## Production Checklist

Before releasing to App Store / Play Store:

### iOS
- [ ] Production `GoogleService-Info.plist` configured
- [ ] App Store Connect bundle ID matches Firebase
- [ ] Correct `REVERSED_CLIENT_ID` in `Info.plist`

### Android
- [ ] **Release SHA-1** fingerprint added to Firebase
- [ ] Production `google-services.json` configured
- [ ] App signing key is the same as the one used for SHA-1

### Both Platforms
- [ ] Test Google Sign-In on physical device
- [ ] Privacy Policy updated to mention Google Sign-In
- [ ] Terms of Service include OAuth usage

---

## Summary

✅ **Firebase Console**: Google Sign-In enabled, support email set  
✅ **iOS**: `Info.plist` configured with `REVERSED_CLIENT_ID`  
✅ **Android**: SHA-1 fingerprint added, `google-services.json` updated  
✅ **Code**: `google_sign_in` package added, `AuthService` implemented  
✅ **Testing**: Sign-in works on iOS and Android

Your Google Sign-In is now fully configured! 🎉
