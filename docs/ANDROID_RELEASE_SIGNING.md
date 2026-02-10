# Android Release Signing Setup

This guide walks you through setting up release signing for your Android app.

## Prerequisites

- Java Development Kit (JDK) installed (comes with Android Studio)
- Access to command line/terminal

## Step 1: Generate Release Keystore

Run this command in your terminal from the project root:

```bash
cd android
keytool -genkey -v -keystore app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Important Notes:

- **Store the passwords securely!** You'll need them for all future updates
- Use a strong password (minimum 6 characters)
- Answer all the prompts (name, organization, location, etc.)
- The keystore file will be created at `android/app/upload-keystore.jks`
- **DO NOT commit the keystore to Git** - it's already in `.gitignore`

### Example Prompt Answers:

```
Enter keystore password: [Create strong password]
Re-enter new password: [Repeat password]
What is your first and last name?
  [Unknown]: Your Name
What is the name of your organizational unit?
  [Unknown]: Development
What is the name of your organization?
  [Unknown]: Game Tracker
What is the name of your City or Locality?
  [Unknown]: Your City
What is the name of your State or Province?
  [Unknown]: Your State
What is the two-letter country code for this unit?
  [Unknown]: US
Is CN=Your Name, OU=Development, O=Game Tracker, L=Your City, ST=Your State, C=US correct?
  [no]: yes

Enter key password for <upload>
  (RETURN if same as keystore password): [Press Enter or create different password]
```

## Step 2: Create key.properties File

Create a file named `key.properties` in the `android/` folder (NOT `android/app/`):

```bash
cd android
touch key.properties
```

Add the following content (replace with your actual passwords):

```properties
storePassword=your_keystore_password_here
keyPassword=your_key_password_here
keyAlias=upload
storeFile=app/upload-keystore.jks
```

**Security Notes:**
- This file is already in `.gitignore` - **DO NOT commit it to Git**
- Keep a secure backup of this file
- Consider using a password manager to store these credentials

## Step 3: Verify Configuration

The `android/app/build.gradle` file has already been configured to use the keystore.

Key sections:
1. Loads `key.properties` at build time
2. Configures `signingConfigs.release` with your keystore
3. Uses release signing for release builds

## Step 4: Test Release Build

Build a release APK or App Bundle:

```bash
# From project root
flutter build appbundle --release

# Or build APK
flutter build apk --release
```

If successful, you'll see:
```
✓ Built build/app/outputs/bundle/release/app-release.aab (XX.XMB)
```

## Step 5: Backup Your Keystore

**CRITICAL:** Back up these files securely:

1. `android/app/upload-keystore.jks` - The keystore file
2. `android/key.properties` - The credentials file

Store them in:
- Secure cloud storage (encrypted)
- Password manager
- External encrypted drive
- **Multiple secure locations**

**If you lose the keystore, you cannot update your app on Google Play!**

## Troubleshooting

### Error: "keystore file does not exist"
- Check that `upload-keystore.jks` is in `android/app/` folder
- Verify the `storeFile` path in `key.properties` is correct

### Error: "keystore password was incorrect"
- Double-check passwords in `key.properties`
- No extra spaces or quotes around passwords

### Error: "Failed to read key from keystore"
- Verify `keyAlias` matches what you used when creating keystore
- Check that `keyPassword` is correct

### Verify Keystore Info

To check your keystore details:

```bash
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload
```

## For Production (Google Play)

When you're ready to publish:

1. Go to [Google Play Console](https://play.google.com/console)
2. Create your app listing
3. Upload the signed App Bundle (`.aab` file)
4. Google Play will handle the final signing (App Signing by Google Play)

## SHA-1 Fingerprint (for Firebase/Google Sign-In)

Get your SHA-1 fingerprint:

```bash
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload
```

Add this SHA-1 to:
- Firebase Console (Project Settings → Your apps → Android app)
- Google Cloud Console (for Google Sign-In)

## Security Checklist

- [ ] Keystore file created and stored securely
- [ ] `key.properties` created with correct credentials
- [ ] Both files backed up in multiple secure locations
- [ ] `key.properties` and `*.jks` in `.gitignore`
- [ ] Never shared passwords in public channels
- [ ] Release build tested successfully
- [ ] SHA-1 fingerprint added to Firebase Console

## Additional Resources

- [Official Flutter Android Deployment Guide](https://docs.flutter.dev/deployment/android)
- [Android App Signing Documentation](https://developer.android.com/studio/publish/app-signing)
- [Google Play App Signing](https://support.google.com/googleplay/android-developer/answer/9842756)
