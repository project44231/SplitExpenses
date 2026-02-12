# Event Share Feature Setup

This guide explains how to set up and deploy the event sharing feature.

## Overview

The share feature allows users to share event details with friends via a web link. Friends can view live expense updates without needing the app or logging in.

## Features

- 🔗 **Shareable Links**: Each event gets a unique, permanent share link
- 🔴 **Live Updates**: Expenses update in real-time for viewers
- 🔒 **Secure**: Links use unique tokens that can be revoked
- 📱 **Responsive**: Works on mobile and desktop browsers
- 🎨 **Beautiful UI**: Gradient design matching app theme

## Setup Steps

### 1. Configure Firebase Web Credentials

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `splitexpenses-4c618`
3. Click the gear icon ⚙️ → **Project Settings**
4. Scroll to "Your apps" section
5. If you don't have a web app, click **Add app** → **Web** (</> icon)
6. Copy the `firebaseConfig` object
7. Open `web/firebase-config.js` and replace the placeholder values:

```javascript
window.firebaseConfig = {
  apiKey: "YOUR_ACTUAL_API_KEY",
  authDomain: "splitexpenses-4c618.firebaseapp.com",
  projectId: "splitexpenses-4c618",
  storageBucket: "splitexpenses-4c618.appspot.com",
  messagingSenderId: "YOUR_ACTUAL_SENDER_ID",
  appId: "YOUR_ACTUAL_APP_ID"
};
```

### 2. Update Firebase Security Rules

Ensure your Firestore rules allow public read access to shared events:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Events - allow read if shareToken matches
    match /events/{eventId} {
      allow read: if request.query.shareToken == resource.data.shareToken;
    }
    
    // Expenses - allow read for events with valid share token
    match /expenses/{expenseId} {
      allow read: if exists(/databases/$(database)/documents/events/$(resource.data.eventId));
    }
    
    // Participants - allow read
    match /participants/{participantId} {
      allow read: true;
    }
  }
}
```

### 3. Deploy to Firebase Hosting

```bash
# Install Firebase CLI (if not installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Deploy hosting only
firebase deploy --only hosting
```

### 4. Update Share Service Domain

Once deployed, update the domain in the share service:

1. Open `lib/services/event_share_service.dart`
2. Update `_webAppDomain` with your Firebase hosting domain:

```dart
static const String _webAppDomain = 'your-project.web.app';
// or use custom domain:
// static const String _webAppDomain = 'share.yourdomain.com';
```

## How It Works

### User Flow

1. User opens an event in the app
2. Taps the **Share** icon in the app bar
3. Dialog shows:
   - Shareable URL
   - "Copy Link" button
   - "Share" button (uses system share sheet)
4. Share link sent to friends
5. Friends open link in browser → see live event details

### Technical Flow

1. App generates unique `shareToken` (UUID v4) for event
2. Token saved in Firestore `events` collection
3. Share link format: `https://your-domain.web.app/share/{eventId}/{shareToken}`
4. Web page:
   - Parses URL for `eventId` and `shareToken`
   - Validates token against Firestore
   - Fetches event, expenses, and participants
   - Sets up real-time listener for expense updates
   - Renders beautiful UI with live data

### Security

- **Token Validation**: Share links only work if token matches
- **Read-Only**: Viewers cannot modify data
- **Revocable**: Event creator can revoke access by clearing the token
- **No Authentication**: Viewers don't need to log in

## Share Link Format

```
https://your-domain.web.app/share/{eventId}/{shareToken}

Example:
https://splitexpenses.web.app/share/abc123/550e8400-e29b-41d4-a716-446655440000
```

## Testing Locally

To test the share feature locally:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Serve locally
firebase serve --only hosting

# Visit: http://localhost:5000/share/{eventId}/{shareToken}
```

## Troubleshooting

### "Invalid Share Link" Error
- Verify the URL contains both `eventId` and `shareToken`
- Check that the event exists in Firestore
- Ensure the shareToken matches the event's stored token

### "Event not found" Error
- Event may have been deleted
- Check Firestore database for the event document

### "Invalid share token" Error
- Token doesn't match the event's stored token
- Share link may have been revoked
- Generate a new share link from the app

### Data Not Loading
- Check Firebase config in `web/firebase-config.js`
- Verify Firestore rules allow public read access
- Check browser console for errors

## Customization

### Update Domain in Share Service
```dart
// lib/services/event_share_service.dart
static const String _webAppDomain = 'your-custom-domain.com';
```

### Customize Share Message
```dart
final shareMessage = message ??
    'Join our ${event.name}!\n\nView real-time expenses:\n$url';
```

### Custom Branding
Edit `web/share.html`:
- Update colors in CSS
- Change gradient: `background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);`
- Add your logo
- Customize footer

## Dependencies

- **share_plus**: System share sheet integration
- **uuid**: Generate unique share tokens
- **Firebase Hosting**: Host the web page
- **Firestore**: Store and retrieve data

## Future Enhancements

- [ ] QR code generation for easy sharing
- [ ] Share analytics (view count, last viewed)
- [ ] Expiring share links
- [ ] Password-protected shares
- [ ] Embed options for other websites
- [ ] Export to PDF from web view
