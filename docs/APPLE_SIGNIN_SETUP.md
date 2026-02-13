# Apple Sign In Setup Guide

This guide walks you through setting up Sign in with Apple for the SplitExpenses app, ensuring compliance with Apple App Store requirements.

## Why Apple Sign In is Required

According to Apple's App Store Review Guidelines (4.8), if your app offers third-party or social login services (like Google Sign-In), you **must** also offer Sign in with Apple as an equivalent option.

## Prerequisites

- Active Apple Developer Account ($99/year)
- Xcode installed on macOS
- Firebase project configured
- App Bundle ID registered

---

## Step 1: Configure Apple Developer Console

### 1.1 Enable Sign in with Apple Capability

1. Go to [Apple Developer Console](https://developer.apple.com/account/)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Select **Identifiers** > Choose your App ID
4. Scroll down and enable **Sign in with Apple**
5. Click **Edit** and configure:
   - Enable as a primary App ID
   - Choose **Enable as a primary App ID**
6. Click **Save**

### 1.2 Create a Service ID (for Web/Android)

1. In Apple Developer Console, go to **Identifiers**
2. Click the **+** button and select **Services IDs**
3. Register a new Services ID:
   - **Description**: `SplitExpenses Web Auth`
   - **Identifier**: `com.yourcompany.splitexpenses.service` (must be unique)
4. Enable **Sign in with Apple**
5. Click **Configure**:
   - **Primary App ID**: Select your app's Bundle ID
   - **Domains and Subdomains**: Add your Firebase auth domain
     - Format: `your-project-id.firebaseapp.com`
   - **Return URLs**: Add Firebase callback URL
     - Format: `https://your-project-id.firebaseapp.com/__/auth/handler`
6. Click **Save** and **Continue**

### 1.3 Create a Key for Apple Sign In

1. In Apple Developer Console, go to **Keys**
2. Click the **+** button
3. Enter a **Key Name**: `SplitExpenses Apple Sign In Key`
4. Enable **Sign in with Apple**
5. Click **Configure** and select your Primary App ID
6. Click **Save** and **Continue**
7. Click **Register**
8. **IMPORTANT**: Download the key file (`.p8`)
   - You can only download this **once**
   - Store it securely
9. Note down:
   - **Key ID** (10-character string)
   - **Team ID** (found in top-right of Apple Developer Console)

---

## Step 2: Configure Firebase

### 2.1 Enable Apple Sign-In Provider

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Authentication** > **Sign-in method**
4. Click on **Apple** in the providers list
5. Click **Enable**
6. Configure OAuth settings:
   - **Services ID**: Enter the Services ID you created (e.g., `com.yourcompany.splitexpenses.service`)
   - **Apple Team ID**: Enter your 10-character Team ID
   - **Key ID**: Enter the Key ID from the downloaded key
   - **Private Key**: Open the `.p8` file and copy/paste the entire contents
7. Click **Save**

### 2.2 Add OAuth Redirect URL to Apple

Firebase will show you the OAuth redirect URI. Copy it and:

1. Return to Apple Developer Console
2. Go to your **Services ID** configuration
3. Add the Firebase OAuth redirect URI to the **Return URLs** list
4. Save the configuration

---

## Step 3: Configure Xcode Project (iOS)

### 3.1 Enable Sign in with Apple Capability

1. Open your project in Xcode
2. Select your target (Runner)
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Search for and add **Sign in with Apple**
6. Ensure your Team is selected in **Signing**

### 3.2 Update Info.plist (if needed)

The capability should automatically configure everything, but verify:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

### 3.3 Build and Test

1. Build the project: `flutter build ios`
2. Run on a real device (Apple Sign In doesn't work in Simulator for production)
3. Test the Sign in with Apple flow

---

## Step 4: Configure Android (Optional)

Apple Sign In on Android uses a web-based flow:

### 4.1 Update AndroidManifest.xml

Ensure you have the internet permission:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### 4.2 Test on Android

The web-based flow should work automatically if Firebase is configured correctly.

---

## Step 5: Testing

### Test Checklist

- [ ] Apple Sign In button appears on login screen
- [ ] Button follows Apple's design guidelines (black background, white text)
- [ ] Tapping button opens Apple Sign In flow
- [ ] Can sign in with existing Apple ID
- [ ] User's name is captured on first sign-in
- [ ] User's email is captured (or hidden if user chooses)
- [ ] Subsequent sign-ins work correctly
- [ ] Sign out and sign back in works
- [ ] Error handling works (user cancels, network errors)
- [ ] Works on both iOS and Android

### Testing Notes

**Sandbox Testing:**
- Use your actual Apple ID for testing
- You can manage test users in App Store Connect > Users and Access > Sandbox Testers

**Email Privacy:**
- Apple allows users to hide their email
- Your app will receive a private relay email (e.g., `abc123@privaterelay.appleid.com`)
- Plan your email verification flow accordingly

---

## App Store Requirements Compliance

### Design Guidelines

✅ **We follow these requirements:**

1. **Equal Prominence**: Apple Sign In button appears **before** Google Sign In
2. **Proper Styling**: 
   - Black background with white text (Apple's standard)
   - Apple logo icon
   - Clear "Sign in with Apple" text
3. **No Misleading UI**: Button clearly indicates it's for Apple Sign In
4. **Functional**: Actual working implementation, not a placeholder

### Review Guidelines

Your app meets Apple's requirements (Section 4.8):

- ✅ Offers Sign in with Apple alongside Google Sign In
- ✅ Apple Sign In is at least as prominent as other options
- ✅ Doesn't require users to set up an account before using app (Guest mode available)
- ✅ Properly handles user data and privacy

---

## Troubleshooting

### Common Issues

**"Sign in with Apple is not configured"**
- Verify the Service ID is correctly configured in Firebase
- Check that the OAuth redirect URL matches exactly
- Ensure the private key is correctly pasted in Firebase

**"Invalid Client"**
- The Bundle ID doesn't match the one in Apple Developer Console
- The Service ID doesn't match the one in Firebase
- Check for typos in IDs

**"Authorization Failed"**
- Make sure Sign in with Apple capability is enabled in Xcode
- Verify the Team ID is correct
- Check that the key hasn't expired or been revoked

**Email not received**
- User may have chosen to hide their email
- Check for the private relay email address
- This is expected behavior; handle accordingly

**Works in debug but not release**
- Ensure the release build has the Sign in with Apple capability
- Verify provisioning profiles include the capability
- Check Firebase configuration for production

### Testing in Development

1. Use a real iOS device (not simulator for full testing)
2. Use TestFlight for beta testing
3. Test both first-time sign-in and returning user flows
4. Test cancellation and error scenarios

---

## Security Best Practices

1. **Nonce Generation**: We use cryptographically secure random nonces (implemented)
2. **Token Validation**: Firebase handles token validation
3. **Secure Storage**: User credentials are never stored locally
4. **HTTPS Only**: All communication is over HTTPS
5. **Error Handling**: Sensitive information is not exposed in error messages

---

## Maintenance

### Regular Tasks

- **Monitor**: Check Firebase Analytics for Apple Sign In usage
- **Update**: Keep `sign_in_with_apple` package updated
- **Review**: Periodically verify Apple Developer account credentials
- **Test**: Test sign-in flow with each major app update

### If You Need to Change Bundle ID

1. Update Bundle ID in Xcode
2. Create new App ID in Apple Developer Console
3. Update Service ID to reference new App ID
4. Update Firebase configuration
5. Retest thoroughly

---

## Support

- **Apple Documentation**: [Sign in with Apple](https://developer.apple.com/sign-in-with-apple/)
- **Firebase Documentation**: [Apple Sign-In](https://firebase.google.com/docs/auth/ios/apple)
- **Package Documentation**: [sign_in_with_apple](https://pub.dev/packages/sign_in_with_apple)

---

## Completion Checklist

Before submitting to App Store:

- [ ] Apple Sign In works on real iOS devices
- [ ] Apple Sign In button is properly styled
- [ ] Button is equally prominent as other sign-in options
- [ ] Error handling is comprehensive
- [ ] Privacy policy mentions Apple Sign In
- [ ] Terms of service are accessible
- [ ] Tested on multiple iOS versions
- [ ] Tested with different Apple IDs
- [ ] Tested email hiding scenario
- [ ] All Firebase configuration is complete
- [ ] App builds successfully for release

---

**Status**: ✅ Implementation Complete (Requires Configuration)

**Next Steps**: Follow this guide to configure Apple Developer Console and Firebase, then test the implementation.
