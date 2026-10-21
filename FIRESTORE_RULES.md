# Firestore Security Rules for GeoDiary

## User Profile Access Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // User profile documents: users/{uid}/profile
    match /users/{userId}/profile {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // User memories: users/{uid}/memories/{memoryId}
    match /users/{userId}/memories/{memoryId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Explanation:

1. **Authentication Required**: All access requires `request.auth != null` (user must be signed in)
2. **User ID Matching**: Users can only access documents where the `userId` in the path matches their own `request.auth.uid`
3. **Path-Based Security**: Security is enforced at the document level based on the URL path structure
4. **Applies to Both Collections**: 
   - Profile documents: `/users/{uid}/profile`
   - Memory documents: `/users/{uid}/memories/{memoryId}`

## Implementation Notes:

- These rules should be deployed to Firebase Console or via Firebase CLI
- The rules leverage Firebase Authentication UIDs for user isolation
- No additional validation rules are needed at this phase since:
  - Profile data comes directly from Google (trusted source)
  - Memory data validation can be added in later phases if needed

## Testing:

Rules can be tested using:
- Firebase Console Rules Playground
- Firebase Emulator Suite
- Unit tests with firebase-admin SDK