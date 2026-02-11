# 📱 Store Submission Quick Checklist

**App:** Game buy-in tracker v1.0.0  
**Date:** February 9, 2026

Use this checklist to track your progress toward App Store and Google Play submission.

---

## 🚀 Quick Start (Do These First)

### 1. Update Contact Information

- [ ] Open `web/privacy-policy.html`
- [ ] Replace `privacy@gametracker.app` with your real email
- [ ] Update developer name in privacy policy (currently "Game Tracker Development")

### 2. Create Android Keystore (15 minutes)

```bash
cd android
keytool -genkey -v -keystore app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

- [ ] Run command above and answer all prompts
- [ ] **Write down passwords in a password manager**
- [ ] Create `android/key.properties` with credentials
- [ ] **Backup keystore file to 3 secure locations**

📄 Full guide: `docs/ANDROID_RELEASE_SIGNING.md`

### 3. Deploy Privacy Policy (30 minutes)

**Option A: Firebase Hosting (Recommended)**

- [ ] Update `firebase.json` to include privacy-policy route
- [ ] Run: `firebase deploy --only hosting`
- [ ] Copy the URL (e.g., `https://your-project.web.app/privacy-policy`)
- [ ] Test URL in browser

**Option B: GitHub Pages or Custom Domain**

- [ ] Follow instructions in `docs/PRIVACY_POLICY_DEPLOYMENT.md`

### 4. Enroll in Apple Developer Program (1-2 days wait)

- [ ] Go to https://developer.apple.com/programs/
- [ ] Pay $99/year
- [ ] Wait for approval email (24-48 hours)
- [ ] Once approved, configure in Xcode (see step 7)

---

## 📸 Create Marketing Materials

### 5. Capture Screenshots (2-3 hours)

**Setup:**
- [ ] Run app on emulator/simulator
- [ ] Create demo game with 4-5 realistic players
- [ ] Add various buy-ins to show activity

**Required Screens:**
- [ ] Active game with player list
- [ ] Add buy-in dialog with quick amounts
- [ ] Settlement screen with transactions
- [ ] Game history list
- [ ] Player statistics/leaderboard
- [ ] Settings or expanded player details
- [ ] Cash-out screen (optional)
- [ ] Live sharing view (optional)

**Android:**
- [ ] Capture 2-8 screenshots at 1080 x 1920 px
- [ ] Create feature graphic at 1024 x 500 px

**iOS:**
- [ ] Capture screenshots for iPhone 14 Pro Max (1290 x 2796)
- [ ] Capture for iPhone 11 Pro Max (1284 x 2778)
- [ ] Capture for iPhone 8 Plus (1242 x 2208)

📄 Full guide: `docs/SCREENSHOT_GUIDE.md`

### 6. Review Marketing Copy

- [ ] Review app description in `docs/APP_STORE_METADATA.md`
- [ ] Choose your favorite short description (80 char)
- [ ] Review keywords for ASO
- [ ] Customize if needed

---

## 🔧 Build & Test

### 7. iOS Setup (After Apple Approval)

- [ ] Open `ios/Runner.xcworkspace` in Xcode
- [ ] Xcode → Settings → Accounts → Add Apple ID
- [ ] Select Runner project → Signing & Capabilities
- [ ] Choose your team from dropdown
- [ ] Verify bundle ID: `com.gametracker.pokerTracker`

📄 Full guide: `docs/IOS_RELEASE_SIGNING.md`

### 8. Build Release Versions

**Android:**
```bash
flutter build appbundle --release
```
- [ ] Build succeeds
- [ ] Output: `build/app/outputs/bundle/release/app-release.aab`

**iOS:**
```bash
flutter build ios --release
```
Then in Xcode:
- [ ] Product → Archive
- [ ] Distribute App → App Store Connect

### 9. Test on Physical Devices

**Android:**
- [ ] Install APK on Android device
- [ ] Test Google Sign-In
- [ ] Test all game features
- [ ] Test offline mode
- [ ] Verify no crashes

**iOS:**
- [ ] Install via Xcode on iPhone
- [ ] Test Google Sign-In
- [ ] Test all game features
- [ ] Test offline mode
- [ ] Verify no crashes

---

## 🏪 Store Account Setup

### 10. Google Play Console

- [ ] Create account at https://play.google.com/console
- [ ] Pay $25 one-time registration fee
- [ ] Verify email and phone

### 11. App Store Connect

- [ ] Included with Apple Developer Program
- [ ] Access at https://appstoreconnect.apple.com/
- [ ] Create app listing

---

## 📝 Google Play Store Submission

### 12. Create App Listing

- [ ] Click "Create app" in Play Console
- [ ] **App details:**
  - Name: Game buy-in tracker
  - Default language: English (US)
  - App/Game: Game
  - Free/Paid: Free
- [ ] Complete declarations

### 13. Store Listing

- [ ] **Short description** (80 char max) - from metadata doc
- [ ] **Full description** (4000 char max) - from metadata doc
- [ ] Upload **app icon** (already configured via Flutter)
- [ ] Upload **feature graphic** (1024 x 500)
- [ ] Upload **screenshots** (2-8 phone screenshots)
- [ ] **Category:** Entertainment
- [ ] **Tags:** poker, games, tracker (optional)

### 14. App Content

- [ ] **Privacy policy URL:** Your deployed URL
- [ ] **Target audience:** 13+ (or 12+)
- [ ] **Content rating questionnaire:**
  - Violence: None
  - Sexual content: None
  - Language: None
  - Gambling: Yes (simulated only, no real money)
- [ ] **News app:** No
- [ ] **COVID-19 contact tracing:** No
- [ ] **Data safety:**
  - Collects: Location (No), Personal info (Yes - Email, Name)
  - Shares: No
  - Security: Data encrypted in transit, Can request data deletion

### 15. Production Release

- [ ] Upload **App Bundle** (.aab file)
- [ ] **Release name:** 1.0.0
- [ ] **Release notes:** Copy from metadata doc
- [ ] **Countries:** Choose availability
- [ ] Review and **Submit for review**

**Review time:** 1-7 days typically

---

## 🍎 Apple App Store Submission

### 16. Create App Listing

- [ ] Go to App Store Connect
- [ ] Click "My Apps" → "+" → "New App"
- [ ] **Platforms:** iOS
- [ ] **Name:** Game buy-in tracker
- [ ] **Primary Language:** English (U.S.)
- [ ] **Bundle ID:** com.gametracker.pokerTracker
- [ ] **SKU:** pokertracker (or any unique ID)

### 17. App Information

- [ ] **Category:** Entertainment
- [ ] **Secondary category:** Lifestyle (optional)
- [ ] **Privacy Policy URL:** Your deployed URL
- [ ] **Subtitle:** (30 char) e.g., "Home Game Tracker"
- [ ] **Promotional text:** (170 char) Optional marketing text

### 18. Pricing and Availability

- [ ] **Price:** Free
- [ ] **Availability:** All territories or select countries

### 19. Version Information

- [ ] **Version:** 1.0.0
- [ ] **Copyright:** © 2026 [Your Name]
- [ ] **Description:** Copy from metadata doc
- [ ] **Keywords:** poker,tracker,home game,settlement,buy-in (100 char max)
- [ ] **Support URL:** Same as privacy or separate support page
- [ ] **Marketing URL:** Optional

### 20. Build Upload

- [ ] Upload IPA via Xcode (Product → Archive → Distribute)
- [ ] Or use Transporter app
- [ ] Wait for processing (15-30 minutes)
- [ ] Select build in App Store Connect

### 21. Media

**iPhone Screenshots:**
- [ ] Upload for 6.7" display (iPhone 14 Pro Max)
- [ ] Upload for 6.5" display (iPhone 11 Pro Max)  
- [ ] Upload for 5.5" display (iPhone 8 Plus)
- [ ] Minimum 3 per size, max 10

**iPad Screenshots (Optional):**
- [ ] Upload for 12.9" display
- [ ] Upload for 11" display

**App Previews (Optional):**
- [ ] Upload video previews (15-30 seconds)

### 22. Age Rating

- [ ] Complete questionnaire
- [ ] **Simulated Gambling:** Infrequent/Mild
- [ ] All other categories: None
- [ ] **Result:** 12+

### 23. App Review Information

- [ ] **Sign-in required:** No (guest mode available)
- [ ] **Contact information:**
  - First name, Last name
  - Phone number
  - Email address
- [ ] **Demo account:** Not needed (guest mode)
- [ ] **Notes:** "App tracks friendly poker games, no real money gambling"

### 24. Submit for Review

- [ ] Review all information
- [ ] Click **"Submit for Review"**
- [ ] Wait for Apple's review (1-3 days typically)

---

## ✅ Post-Submission

### 25. Monitor Status

**Google Play:**
- [ ] Check Play Console for review status
- [ ] Respond to any review questions within 7 days

**App Store:**
- [ ] Check App Store Connect for review status
- [ ] App Store team may request clarifications

### 26. After Approval

- [ ] Test download from actual stores
- [ ] Verify app listing looks correct
- [ ] Share store links with friends/testers
- [ ] Monitor user reviews and ratings
- [ ] Plan first update (bug fixes, new features)

### 27. Marketing (Optional)

- [ ] Post on social media
- [ ] Share with poker communities
- [ ] Submit to app review sites
- [ ] Create landing page
- [ ] Send press release

---

## 📞 Support & Resources

### Documentation
- `docs/APP_STORE_READINESS_SUMMARY.md` - Comprehensive overview
- `docs/ANDROID_RELEASE_SIGNING.md` - Android keystore guide
- `docs/IOS_RELEASE_SIGNING.md` - iOS signing guide
- `docs/PRIVACY_POLICY_DEPLOYMENT.md` - Privacy policy hosting
- `docs/APP_STORE_METADATA.md` - All marketing copy
- `docs/SCREENSHOT_GUIDE.md` - Screenshot instructions

### Official Resources
- Flutter Deployment: https://docs.flutter.dev/deployment
- Google Play Help: https://support.google.com/googleplay/android-developer
- App Store Connect Help: https://help.apple.com/app-store-connect/
- Firebase Console: https://console.firebase.google.com/

### Need Help?
- Flutter Discord: https://discord.gg/flutter
- Stack Overflow: Tag with `flutter` or `app-store-submission`

---

## ⏱️ Estimated Timeline

| Phase | Time | Notes |
|-------|------|-------|
| Update contact info | 5 min | Just email addresses |
| Create keystore | 15 min | Write down passwords! |
| Deploy privacy policy | 30 min | Firebase or GitHub |
| Apple enrollment wait | 1-2 days | After payment |
| Screenshot capture | 2-3 hrs | Most time-consuming |
| iOS signing setup | 1 hr | After Apple approval |
| Build & test | 2-3 hrs | On physical devices |
| Store listing creation | 2 hrs | Both stores |
| Google Play review | 1-7 days | Automated mostly |
| App Store review | 1-3 days | Manual review |

**Total active work:** ~10-15 hours  
**Total calendar time:** ~5-10 days (with waits)

---

## 🎯 Critical Reminders

⚠️ **NEVER lose your Android keystore** - Back up to 3+ secure locations  
⚠️ **Keep passwords secure** - Use a password manager  
⚠️ **Test on real devices** - Emulators don't catch everything  
⚠️ **Read rejection reasons carefully** - Both stores may request changes  
⚠️ **Be patient** - Reviews take time, especially first submission  

---

## 🎉 You're Ready!

Everything is configured and ready to go. Follow this checklist step by step, and you'll be live on both stores soon!

**Good luck with your launch! 🚀**

---

*Created: February 9, 2026*  
*Last updated: February 9, 2026*
