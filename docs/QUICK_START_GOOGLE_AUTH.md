# Quick Start: Google Authentication

Fast track guide to get Google Sign-In working in 10 minutes.

## Prerequisites

- Firebase project created
- App registered in Firebase (iOS and/or Android)
- Flutter app running locally

---

## 🚀 Quick Setup (3 Steps)

### Step 1: Enable Google Sign-In in Firebase (2 min)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. **Authentication** → **Sign-in method** tab
4. Click **Google** → Toggle **Enable**
5. Set **Project support email** (your email)
6. Click **Save**

### Step 2: Platform Configuration

#### For iOS (3 min)

1. Open `ios/Runner/GoogleService-Info.plist`
2. Find the value for key `REVERSED_CLIENT_ID` (looks like `com.googleusercontent.apps.123456789-abc`)
3. Open `ios/Runner/Info.plist`
4. Add this (replace `YOUR_REVERSED_CLIENT_ID` with value from step 2):

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>YOUR_REVERSED_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

5. Install pods:
```bash
cd ios
pod install
cd ..
```

#### For Android (5 min)

1. Get your SHA-1 fingerprint:
```bash
cd android
./gradlew signingReport
```

2. Copy the **SHA-1** from **Variant: debug** section

3. Add to Firebase:
   - Firebase Console → **Project Settings** → **Your apps** → Android
   - Scroll to **SHA certificate fingerprints**
   - Click **Add fingerprint** → Paste SHA-1 → **Save**

4. Download updated `google-services.json`:
   - Firebase Console → **Project Settings** → Android app
   - Download **google-services.json**
   - Replace `android/app/google-services.json`

### Step 3: Test (2 min)

```bash
flutter clean
flutter pub get
flutter run
```

**In the app:**
1. Tap "Sign in with Google"
2. Select Google account
3. Should navigate to home screen
4. Check Firebase Console → Authentication → Users to see your account

---

## ✅ That's it!

If it works, you're done! 🎉

If not, see the detailed troubleshooting guide in `GOOGLE_SIGNIN_SETUP.md`.

---

## Common Issues

### iOS: "Invalid client ID"
- **Fix**: Double-check `REVERSED_CLIENT_ID` in `Info.plist`
- Clean build: `flutter clean && cd ios && pod install && cd .. && flutter run`

### Android: "sign_in_failed"
- **Fix**: Make sure SHA-1 is added to Firebase Console
- **Verify**: SHA-1 in Firebase matches output from `./gradlew signingReport`

### Button does nothing
- **Check**: Internet connection
- **Check**: Google Sign-In is enabled in Firebase Console
- **Logs**: Run `flutter run --verbose` to see error messages

---

## Next Steps

- ✅ Google Sign-In working
- 📝 Setup Apple Sign-In (optional)
- 📝 Add email/password authentication (optional)
- 📝 Implement account linking (advanced)

For detailed setup, troubleshooting, and production checklist, see **[GOOGLE_SIGNIN_SETUP.md](GOOGLE_SIGNIN_SETUP.md)**.
