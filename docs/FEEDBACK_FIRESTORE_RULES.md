# Firestore Security Rules for Feedback Feature

## Overview
This document contains the Firestore security rules that need to be added to support the feedback feature.

## Instructions
1. Go to Firebase Console: https://console.firebase.google.com
2. Select your project
3. Navigate to Firestore Database → Rules
4. Add the rules below to your existing rules configuration

## Feedback Collection Rules

Add these rules to your Firestore security rules:

```javascript
// Feedback collection rules
match /feedback/{feedbackId} {
  // Allow users to create feedback submissions
  allow create: if request.auth != null 
                && request.resource.data.userId == request.auth.uid;
  
  // Allow users to read only their own feedback
  allow read: if request.auth != null 
              && resource.data.userId == request.auth.uid;
  
  // Feedback is immutable once submitted - no updates or deletes allowed
  allow update, delete: if false;
}
```

## Storage Rules for Feedback Images

Add these rules to your Firebase Storage security rules:

```javascript
// Feedback images storage rules
match /feedback_images/{userId}/{imageId} {
  // Allow authenticated users to write to their own folder
  allow write: if request.auth != null 
               && request.auth.uid == userId;
  
  // Allow authenticated users to read feedback images
  allow read: if request.auth != null;
}
```

## Complete Example

Here's how your rules might look with the feedback rules included:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ... your existing rules for games, players, etc. ...
    
    // Feedback collection
    match /feedback/{feedbackId} {
      allow create: if request.auth != null 
                    && request.resource.data.userId == request.auth.uid;
      allow read: if request.auth != null 
                  && resource.data.userId == request.auth.uid;
      allow update, delete: if false;
    }
  }
}
```

## Storage Rules Example

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // ... your existing storage rules ...
    
    // Feedback images
    match /feedback_images/{userId}/{imageId} {
      allow write: if request.auth != null 
                   && request.auth.uid == userId;
      allow read: if request.auth != null;
    }
  }
}
```

## Firestore Indexes

The Firestore indexes have already been updated in `firestore.indexes.json`. To deploy them:

```bash
firebase deploy --only firestore:indexes
```

Or the indexes will be automatically created when you first run queries that require them.

## Security Considerations

1. **Immutability**: Feedback submissions cannot be edited or deleted after submission
2. **User Isolation**: Users can only read their own feedback submissions
3. **Authentication Required**: All feedback operations require authentication
4. **Image Upload Restrictions**: Users can only upload images to their own folder

## Testing

After updating the rules, test the feedback feature:
1. Submit feedback with images
2. Try to read another user's feedback (should fail)
3. Try to update existing feedback (should fail)
4. Try to delete feedback (should fail)
