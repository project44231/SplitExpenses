# Privacy Policy Deployment Guide

Your privacy policy has been created at `web/privacy-policy.html`. This guide explains how to deploy it and configure your app store listings.

## Important: Update Contact Information

Before deploying, **you must update the contact email** in the privacy policy:

1. Open `web/privacy-policy.html`
2. Find line with: `privacy@gametracker.app`
3. Replace with your actual email address
4. Save the file

## Deployment Options

### Option 1: Firebase Hosting (Recommended)

Your project already has Firebase Hosting configured for the game sharing feature. Adding the privacy policy is simple:

#### Steps:

1. Update `firebase.json` to include privacy policy:

```json
{
  "hosting": {
    "public": "web",
    "rewrites": [
      {
        "source": "/share",
        "destination": "/share/index.html"
      },
      {
        "source": "/privacy-policy",
        "destination": "/privacy-policy.html"
      }
    ]
  }
}
```

2. Deploy to Firebase Hosting:

```bash
firebase deploy --only hosting
```

3. Your privacy policy will be accessible at:
```
https://YOUR-PROJECT-ID.web.app/privacy-policy
```

**To find your Firebase URL:**
```bash
firebase hosting:channel:list
```

Or check the Firebase Console → Hosting section.

### Option 2: GitHub Pages

If you want to host on GitHub:

1. Create a new repository called `poker-tracker-legal`
2. Copy `privacy-policy.html` to the repository
3. Rename it to `index.html`
4. Go to repository Settings → Pages
5. Enable GitHub Pages from `main` branch
6. Your URL will be: `https://YOUR-USERNAME.github.io/poker-tracker-legal/`

### Option 3: Custom Domain

If you have your own domain:

1. Upload `privacy-policy.html` to your web server
2. Make it accessible at `https://yourdomain.com/privacy-policy`
3. Ensure HTTPS is enabled (required by app stores)

### Option 4: Free Static Hosting Services

Other options:
- **Netlify**: Drag and drop deployment, free tier
- **Vercel**: Great for static sites, free tier
- **Cloudflare Pages**: Free static hosting

## After Deployment

### 1. Test the URL

Make sure your privacy policy is publicly accessible:
- Open the URL in a browser
- Verify it loads correctly
- Check it works on mobile devices
- Ensure HTTPS is enabled

### 2. Update App Store Listings

#### Google Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app
3. Go to **Store presence → Privacy Policy**
4. Enter your privacy policy URL
5. Save changes

#### App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Select your app
3. Go to **App Information**
4. Under **General Information**, find **Privacy Policy URL**
5. Enter your privacy policy URL
6. Save changes

### 3. Add to App (Optional but Recommended)

Add a link to privacy policy in your app:

1. In Settings/Profile screen, add a "Privacy Policy" button
2. Open the URL using `url_launcher` package
3. Consider adding "Terms of Service" link too

Example code location: `lib/features/profile/screens/profile_screen.dart`

## Firebase Hosting Configuration

If deploying via Firebase, here's the complete `firebase.json` configuration:

```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "storage": {
    "rules": "storage.rules"
  },
  "hosting": {
    "public": "web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "/share",
        "destination": "/share/index.html"
      },
      {
        "source": "/privacy-policy",
        "destination": "/privacy-policy.html"
      }
    ],
    "headers": [
      {
        "source": "**",
        "headers": [
          {
            "key": "X-Content-Type-Options",
            "value": "nosniff"
          },
          {
            "key": "X-Frame-Options",
            "value": "DENY"
          }
        ]
      }
    ]
  }
}
```

## Verification Checklist

- [ ] Contact email updated in privacy policy
- [ ] Privacy policy deployed to public URL
- [ ] URL is HTTPS (secure)
- [ ] Privacy policy loads correctly in browser
- [ ] URL works on mobile devices
- [ ] URL added to Google Play Console listing
- [ ] URL added to App Store Connect listing
- [ ] Privacy policy link added to app (optional)
- [ ] Support email set up (same as in privacy policy)

## Legal Compliance

### What Your Privacy Policy Covers

✅ Data collection (explicit and automatic)
✅ Third-party services (Firebase, Google Sign-In)
✅ Data usage and storage
✅ User rights (access, deletion, export)
✅ Security measures
✅ California privacy rights (CCPA)
✅ European privacy rights (GDPR)
✅ Children's privacy (COPPA compliance)
✅ Contact information

### Additional Considerations

1. **Terms of Service** (optional but recommended):
   - Consider creating terms of service separately
   - Define acceptable use, disclaimers, liability limits

2. **Age Rating Consistency**:
   - Privacy policy states not for users under 13
   - Set app store age rating to 12+ or higher

3. **Gambling Disclaimer**:
   - Clarify that app is for home game tracking only
   - No real money gambling facilitated
   - Include in app description and/or terms

4. **Data Retention**:
   - Guest data cleanup policy mentioned
   - 30-day deletion window for account deletion
   - Keep records of data deletion requests

## Support Email Setup

You'll need a support email for:
- Privacy policy contact
- App store listings (support URL)
- User inquiries
- Legal compliance

Recommended email format:
- `support@gametracker.app`
- `privacy@gametracker.app`
- Or use a personal email if preferred

Create a simple support page or use your privacy policy URL as the support URL in app stores.

## Regular Updates

Review and update your privacy policy:
- When you add new features that collect data
- When you integrate new third-party services
- When privacy laws change
- At least once per year

Always update the "Last Updated" date when making changes.

## Resources

- [Google Play Privacy Policy Requirements](https://support.google.com/googleplay/android-developer/answer/9859455)
- [App Store Privacy Policy Requirements](https://developer.apple.com/app-store/review/guidelines/#privacy)
- [Firebase Privacy Information](https://firebase.google.com/support/privacy)
- [GDPR Compliance Guide](https://gdpr.eu/)
- [CCPA Compliance Guide](https://oag.ca.gov/privacy/ccpa)

## Need Help?

If you need legal advice on privacy policies:
- Consult a lawyer specializing in privacy law
- Use privacy policy generators (TermsFeed, PrivacyPolicies.com)
- Review privacy policies of similar apps for reference

**Disclaimer:** This is a template privacy policy. Consider consulting with a legal professional to ensure full compliance with applicable laws in your jurisdiction.
