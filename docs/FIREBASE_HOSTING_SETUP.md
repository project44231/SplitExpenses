# Firebase Hosting Setup for Live Game Sharing

This guide explains how to deploy the web viewer for live game sharing.

## Prerequisites

- Firebase CLI installed: `npm install -g firebase-tools`
- Firebase project initialized (already done)

## Files Created

- `web/share/index.html` - Web viewer UI
- `web/share/app.js` - Firebase integration and real-time updates
- `firebase.json` - Firebase Hosting configuration
- `.firebaserc` - Firebase project configuration

## Deployment Steps

### 1. Login to Firebase

```bash
firebase login
```

### 2. Deploy to Firebase Hosting

```bash
firebase deploy --only hosting
```

This command will:
- Upload the `web/share/` folder contents to Firebase Hosting
- Make the web viewer accessible at: `https://splitpot.web.app/share/{gameId}/{shareToken}`

### 3. Test the Deployment

After deployment, you can test by:
1. Starting an active game in the app
2. Tapping the "Share" button in the app
3. Opening the generated URL in a web browser
4. Verifying that you see live game standings

## How It Works

### URL Structure

```
https://splitpot.web.app/share/{gameId}/{shareToken}
```

- `gameId`: The unique ID of the active game
- `shareToken`: Random UUID for access control

### Real-Time Updates

The web viewer uses Firestore's `onSnapshot` to listen for:
- Game data changes (duration, player count)
- Buy-in updates (new buy-ins, modifications)

Updates appear instantly on all connected devices.

### Security

- Share tokens are unique per game
- Links stay active permanently (as per user preference)
- Read-only access - players cannot modify data
- No authentication required for viewing

## Updating the Web Viewer

If you make changes to the web viewer:

```bash
# Edit files in web/share/
firebase deploy --only hosting
```

Changes will be live immediately.

## Troubleshooting

### Issue: Web viewer not loading

1. Check Firebase console for deployment status
2. Verify the Firebase config in `web/share/app.js` matches your project
3. Check browser console for errors

### Issue: "Game not found" error

1. Verify the game exists in Firestore
2. Check that the shareToken in the URL matches the game's shareToken field
3. Ensure Firestore rules allow public read access for games with shareToken

### Issue: Players not updating in real-time

1. Check network connectivity
2. Verify Firestore indexes are created
3. Check browser console for permission errors

## Custom Domain (Optional)

To use a custom domain like `play.yourdomain.com`:

1. Go to Firebase Console → Hosting
2. Click "Add custom domain"
3. Follow the DNS configuration steps
4. Update `_webAppDomain` in `lib/services/game_share_service.dart`

## Cost Considerations

- Firebase Hosting has a generous free tier
- Typical usage:
  - Storage: ~1KB per deployment
  - Bandwidth: ~50KB per game view
  - Well within free tier limits for personal use

## Next Steps

After deployment, the share button in the app will automatically generate working links!
