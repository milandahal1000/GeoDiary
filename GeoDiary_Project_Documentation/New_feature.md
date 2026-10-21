# GeoDiary --- New Features Documentation

This document outlines the new features to be implemented for the GeoDiary application as part of the Firebase authentication and Firestore integration update.

## Overview

The original GeoDiary plan focused on local SQLite storage without authentication or a backend. This document describes the approved changes to implement:

- Google Sign-In for user authentication
- Firebase Authentication for managing accounts and sessions  
- Cloud Firestore for storing authenticated users' journal data
- Enhanced BLoC architecture for separation of concerns
- Secure user-specific data access

## Implementation Phases

### Phase 1: Firebase Project Setup & Initialization
**Goal**: Configure Firebase project and initialize in the Flutter app

#### Features:
1. Firebase project creation/configuration in Firebase Console
2. Google Sign-In authentication method enabled
3. Android app registration with Firebase
4. google-services.json configuration file
5. firebase_options.dart generation via FlutterFire CLI
6. Firebase initialization in main.dart
7. cloud_firestore dependency addition
8. Basic Firebase connectivity verification

#### User Experience:
- App starts and initializes Firebase silently
- No visible changes to user interface yet
- Basic error handling for Firebase initialization failures

### Phase 2: Authentication System & Login Screen
**Goal**: Implement Google Sign-In flow and authentication state management

#### Features:
1. Authentication service/repository layer
2. Authentication BLoC/Cubit for state management
3. Polished login screen following GeoDiary design system:
   - App name: "GeoDiary"
   - Tagline: "Your memories, mapped."
   - Nature-inspired green color palette
   - Prominent "Continue with Google" button
   - Loading feedback during authentication
   - User-friendly error messages
4. Google Sign-In integration with proper API usage
5. Firebase Authentication credential handling
6. Authentication state change listener
7. Sign-out functionality
8. Authentication-aware navigation (login vs home screen)

#### User Experience:
- On app launch: Check auth state
- If not signed in: Show login screen
- If signed in: Navigate to home/journal screen
- Tap "Continue with Google" → Google account selection → Firebase sign-in
- Loading indicator during auth process
- Clear error messages for failed attempts
- Successful sign-in navigates to home screen
- Sign-out returns to login screen

### Phase 3: Firestore Profile Management
**Goal**: Create and manage user profile documents in Firestore

#### Features:
1. User profile model with fields:
   - uid (Firebase Authentication UID)
   - displayName (from Google)
   - email (from Google)
   - photoUrl (profile image URL from Google)
   - createdAt (server timestamp on first creation)
   - updatedAt (server timestamp on updates)
   - lastLoginAt (server timestamp updated on login)
2. User profile repository/service for Firestore operations:
   - Create or update profile on sign-in
   - Retrieve current user profile
   - Handle optional profile fields safely
   - Preserve createdAt on subsequent logins
   - Use merge strategy for updates
3. Firestore security rules for profile access:
   - Users can read/write only their own profile
   - Authentication required for profile access
4. Integration with authentication flow:
   - Auto-create/update profile after successful sign-in
   - Error handling for profile operations

#### User Experience:
- Profile created automatically on first sign-in
- Profile updated with latest Google info on subsequent sign-ins
- No visible profile management UI in this phase (handled automatically)
- Seamless experience - user doesn't need to manage profile manually

### Phase 4: Firestore Memory Storage
**Goal**: Store journal memories in Firestore with user-specific access

#### Features:
1. Firestore schema for memories:
   - Collection: `users/{uid}/memories/{memoryId}`
   - Memory document fields adapted from existing Memory model:
     - id (string, Firestore document ID)
     - title (string)
     - description (string, optional)
     - visitDate (timestamp)
     - latitude (double, optional)
     - longitude (double, optional)
     - address (string, optional)
     - photoUrl or photoPath (string - reference to stored image)
     - createdAt (timestamp)
     - updatedAt (timestamp)
2. Memory repository/service for Firestore operations:
   - Read user's memories (scoped to uid)
   - Add new memory document
   - Update existing memory document
   - Delete memory document
   - Proper error handling
3. Firestore security rules for memory access:
   - Users can read/write only their own memories
   - Authentication required for memory access
   - Path-based security (`users/{uid}/memories/{memoryId}`)
   - Optional: Validate uid field matches auth context if stored in document
4. Image storage approach:
   - Continue using local storage for images (Phase 1)
   - Store image references/paths in Firestore
   - Note: Cloud image upload requires Firebase Storage (future phase)

#### User Experience:
- Memories saved to Firestore when online
- Memories still accessible via local SQLite cache/offline
- Automatic synchronization between local and cloud (to be implemented)
- User data isolated by Firebase UID
- Same memory CRUD interface, now backed by Firestore

### Phase 5: Offline-First Synchronization Strategy
**Goal**: Implement robust offline capabilities with conflict resolution

#### Features:
1. Local SQLite as primary responsive source (unchanged)
2. Firestore as cloud synchronization backend
3. Synchronization service to handle:
   - Uploading local changes to Firestore when online
   - Downloading remote changes from Firestore when online
   - Conflict detection and resolution strategies
   - Offline queue for operations when no connectivity
4. Timestamp-based conflict resolution (last-write-wins with manual review option)
5. Selective synchronization (only current user's data)
6. Network connectivity monitoring
7. Manual sync trigger option (pull-to-refresh, sync button)

#### User Experience:
- App works fully offline using local SQLite
- When online: Automatic background sync
- Visual indicators for sync status
- Conflict resolution UI when needed
- No data loss when switching between online/offline
- Preserves existing local-first behavior

### Phase 6: Enhanced Security & Privacy Features
**Goal**: Implement security best practices and privacy protections

#### Features:
1. Comprehensive Firestore security rules:
   - Strict ownership validation
   - Input validation where practical
   - Prevention of privilege escalation
   - Secure handling of optional fields
2. Authentication security:
   - Proper Google Sign-In sign-out (clearing Google auth state)
   - Secure handling of authentication tokens
   - Session management best practices
3. Data minimization:
   - Only store necessary user data in Firestore
   - No sensitive data logging
   - Secure handling of optional profile fields
4. Privacy controls:
   - Clear explanation of data usage
   - Option to disconnect Google account
   - Data export capability (foundation for future)
5. Audit logging foundation (server-side, not in client app)

#### User Experience:
- Transparent security - user doesn't see complexity
- Trust indicators for data protection
- Clear privacy disclosures
- Easy account disconnection
- Confidence that data is properly secured

## Design & Technical Specifications

### Authentication Flow
1. App initialization → Firebase initialization
2. Auth state listener checks current user
3. If null → Show login screen
4. If user exists → Validate session → Navigate to home
5. Login screen → "Continue with Google" button
6. Google Sign-In → Account selection → Consent screen
7. Google credentials → Firebase Auth signInWithCredential
8. On success → Create/update user profile in Firestore
9. Navigate to authenticated home screen
10. On failure → Show appropriate error message
11. On cancellation → Return to login screen (no error)

### Firestore Data Structure
```
/users/{uid} (document)
  - uid: string
  - displayName: string
  - email: string
  - photoUrl: string
  - createdAt: timestamp
  - updatedAt: timestamp
  - lastLoginAt: timestamp

/users/{uid}/memories/{memoryId} (document)
  - id: string (matches memoryId)
  - title: string
  - description: string (optional)
  - visitDate: timestamp
  - latitude: double (optional)
  - longitude: double (optional)
  - address: string (optional)
  - photoUrl: string (reference to local/stored image)
  - createdAt: timestamp
  - updatedAt: timestamp
```

### Color Scheme Implementation
- Primary Green: `#287D65` (buttons, accents)
- Deep Green: `#205B4C` (pressed states, deep elements)
- Soft Sage: `#E1EEE7` (backgrounds, subtle elements)
- Background: `#F7F8F5` (main app background)
- These colors will be applied to login screen and extended throughout app

### Navigation Structure
- Unauthenticated: Login screen only
- Authenticated: 
  - Home/Journal screen (main)
  - Add Memory screen
  - Memory Detail screen
  - Edit Memory screen
  - Map screen
  - Profile/Account screen (future phase)
- Auth guards on all protected routes
- Automatic redirect to login when auth state changes to null

## Dependencies to Add
1. cloud_firestore: latest compatible version
2. Additional FlutterFire packages as needed for future phases
3. Any required platform-specific dependencies

## Files to Create/Modify
### New Files:
- lib/services/authentication_service.dart
- lib/repositories/authentication_repository.dart
- lib/bloc/authentication_bloc.dart
- lib/bloc/authentication_state.dart
- lib/bloc/authentication_event.dart
- lib/features/auth/presentation/pages/login_page.dart
- lib/models/user_profile.dart
- lib/repositories/user_profile_repository.dart
- lib/services/firestore_memory_service.dart
- lib/repositories/firestore_memory_repository.dart
- lib/constants/app_routes.dart (add auth routes)
- lib/theme/auth_theme.dart (login screen specific styles)
- firebase_options.dart (generated)
- android/app/google-services.json (from Firebase Console)
- Firestore security rules (firestore.rules)

### Existing Files to Modify:
- lib/main.dart (add Firebase initialization)
- lib/routes/app_routes.dart (add login route, protect routes)
- lib/routes/route_names.dart (add auth route names)
- pubspec.yaml (add cloud_firestore)
- lib/features/journal/presentation/pages/* (add auth checks where needed)
- lib/core/database/database_helper.dart (evaluate for sync strategy)
- lib/features/journal/data/memory_repository.dart (abstract for dual storage)

## Testing Strategy
### Unit Tests:
- Authentication service methods
- BLoC state transitions
- User profile model validation
- Firestore repository operations (mocked)
- Auth guards and navigation logic

### Widget Tests:
- Login screen rendering and button interactions
- Loading and error states
- Authenticated/unauthenticated screen transitions

### Integration Tests:
- Complete sign-in flow (with mocked Firebase)
- Profile creation/update verification
- Memory CRUD operations with Firestore
- Authentication state persistence
- Sign-out and cleanup verification

### Manual Testing:
- Real Google Sign-In flow on device/emulator
- Firestore data verification in console
- Offline functionality testing
- Network interruption handling
- Account linking/unlinking

## Risks and Mitigations
1. **Firebase Configuration Errors**: 
   - Mitigation: Step-by-step verification, clear error messages
2. **Authentication Flow Issues**:
   - Mitigation: Comprehensive error handling, fallback to login screen
3. **Data Loss During Migration**:
   - Mitigation: Preserve local SQLite, bidirectional sync strategy
4. **Offline Sync Conflicts**:
   - Mitigation: Clear conflict resolution strategy, user notification
5. **Performance Impact**:
   - Mitigation: Efficient queries, proper indexing, pagination

## Success Criteria
1. Users can sign in with Google account successfully
2. User profile is created/updated in Firestore automatically
3. Memories are stored in Firestore with proper user isolation
4. App functions offline using local SQLite
5. Data synchronizes between local and cloud when online
6. Security rules prevent unauthorized data access
7. Authentication state persists across app restarts
8. Clear user feedback for all auth states and errors
9. Existing local memories remain accessible and migratable
10. All existing functionality preserved with enhancements

## Future Phases (Beyond Scope)
1. Firebase Storage for cloud photo storage
2. Advanced synchronization with conflict resolution UI
3. Multi-device synchronization testing
4. Account management (disconnect, delete data)
5. Data export/import functionality
6. Social features (optional sharing)
7. Enhanced search and filtering backed by Firestore
8. Analytics and usage tracking (privacy-first)
9. Push notifications for updates/reminders
10. Premium features/subscription model

---
*This document serves as a living specification for the Firebase integration project. Features may be adjusted based on technical feasibility, user feedback, and evolving requirements.*