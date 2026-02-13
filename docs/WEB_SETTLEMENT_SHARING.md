# Web Settlement Sharing Setup

## Overview

Share settlement screens as beautiful web links that anyone can view in their browser.

---

## Quick Setup (5 Steps)

### Step 1: Update Firebase Config in Web Page

Edit `web/settlement.html` (line 186) with your Firebase config:

```javascript
const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT_ID.appspot.com",
    messagingSenderId: "YOUR_SENDER_ID",
    appId: "YOUR_APP_ID"
};
```

**Where to find these values:**
- Firebase Console → Project Settings → Your apps → Web app

### Step 2: Update Base URL in Service

Edit `lib/services/settlement_share_service.dart` (line 56):

```dart
const baseUrl = 'https://YOUR_PROJECT_ID.web.app';
```

Replace `YOUR_PROJECT_ID` with your actual Firebase project ID.

### Step 3: Deploy Firestore Rules

```bash
firebase deploy --only firestore:rules
```

This enables public read access for shared settlements.

### Step 4: Initialize Firebase Hosting

```bash
# Install Firebase CLI (if not already installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize hosting in your project
cd /path/to/SplitExpenses
firebase init hosting
```

**During init, choose:**
- Public directory: `web`
- Configure as single-page app: `No`
- Set up automatic builds: `No`
- Overwrite existing files: `No`

### Step 5: Deploy to Firebase Hosting

```bash
firebase deploy --only hosting
```

Your settlement sharing is now live!

---

## How It Works

### User Flow:

1. User taps **"Share"** button on settlement screen
2. App creates unique web link (e.g., `https://yourapp.web.app/settlement/123456`)
3. Settlement data saved to Firestore with share ID
4. Link shared via native share dialog
5. Recipients open link in any browser
6. Beautiful web page displays the settlement

### Features:

- ✅ **Permanent links** - Don't expire
- ✅ **No login required** - Anyone with link can view
- ✅ **Mobile responsive** - Works on all devices
- ✅ **Beautiful design** - Modern gradient UI
- ✅ **Copy link** - Tap "Copy" in app to copy URL
- ✅ **Access tracking** - Counts how many times viewed

---

## Testing

### Test Locally:

```bash
# Serve locally
firebase serve --only hosting

# Open in browser
http://localhost:5000/settlement.html?id=test123
```

### Test After Deploy:

1. Create a settlement in your app
2. Tap "Share" button
3. Copy the generated link
4. Open link in browser
5. Verify settlement displays correctly

---

## Firebase Console URLs

After deploying, your URLs will be:

- **Primary**: `https://YOUR_PROJECT_ID.web.app/settlement/SHARE_ID`
- **Alternative**: `https://YOUR_PROJECT_ID.firebaseapp.com/settlement/SHARE_ID`

---

## Firestore Data Structure

### Collection: `shared_settlements`

```javascript
{
  shareId: "1707638400000123",
  eventName: "Weekend Trip",
  eventDate: "2026-02-11T10:30:00.000Z",
  currency: {
    code: "USD",
    symbol: "$",
    name: "US Dollar"
  },
  participantResults: [
    {
      participantId: "abc123",
      name: "John Doe",
      totalPaid: 500.00,
      totalOwed: 350.00,
      balance: 150.00,
      expenseCount: 5
    }
  ],
  transactions: [
    {
      from: "Jane Smith",
      to: "John Doe",
      amount: 75.50
    }
  ],
  createdAt: Timestamp,
  accessCount: 12,
  lastAccessedAt: Timestamp
}
```

---

## Security

### Public Access (Intentional):
- ✅ Anyone with link can view
- ✅ No authentication required
- ✅ Only settlement summaries (no sensitive data)

### Protected:
- ❌ Cannot create without authentication
- ❌ Cannot list all settlements
- ❌ Cannot modify existing settlements
- ❌ Need specific share ID to access

### Best Practices:
- Don't include sensitive notes in settlements
- Share IDs are long and hard to guess
- Can delete shared settlements anytime
- Access tracking for monitoring

---

## Customization

### Update Web Page Styling:

Edit `web/settlement.html`:
- Colors (line 20-21): Change gradient colors
- Fonts (line 15): Update font family
- Layout: Modify HTML structure (line 220+)

### Add Your Branding:

```html
<div class="footer">
    Powered by <a href="https://yourwebsite.com">Your Company</a>
</div>
```

---

## Maintenance

### Deploy Updates:

```bash
# Deploy everything
firebase deploy

# Deploy only hosting
firebase deploy --only hosting

# Deploy only rules
firebase deploy --only firestore:rules
```

### Monitor Usage:

- Firebase Console → Hosting → Dashboard
- Check bandwidth and request counts
- View most accessed settlements

---

## Troubleshooting

**"Settlement not found"**
- Check if Firestore rules deployed
- Verify share ID in URL is correct
- Check Firebase console for the document

**"Failed to load settlement"**
- Verify Firebase config in `settlement.html`
- Check browser console for errors
- Ensure hosting is deployed

**Links not working**
- Update base URL in `settlement_share_service.dart`
- Verify Firebase Hosting is active
- Check rewrites in `firebase.json`

---

## Cost Considerations

Firebase Free Plan (Spark) includes:
- **10 GB hosting storage** (plenty for web pages)
- **360 MB/day bandwidth** (~10,000 page views)
- **Unlimited Firestore reads** (25,000/day on free tier)

Estimate: ~500-1000 settlement shares/month on free tier.

---

## Commands Summary

```bash
# Initial setup
firebase login
firebase init hosting
firebase deploy

# Deploy updates
firebase deploy --only hosting

# Test locally
firebase serve --only hosting

# View hosting URL
firebase hosting:sites:list
```

---

## Next Steps

1. ✅ Run Step 1-2 (Update configs with your Firebase project)
2. ✅ Run Step 3 (Deploy Firestore rules)
3. ✅ Run Step 4-5 (Initialize and deploy hosting)
4. ✅ Test by creating and sharing a settlement
5. ✅ Share the web link with others!

---

**Status**: ✅ Code Complete | ⚙️ Requires Firebase Hosting Setup
