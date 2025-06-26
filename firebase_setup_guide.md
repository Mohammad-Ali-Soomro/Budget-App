# Firebase Setup Guide for Production

## Current Status
The app is currently configured with demo/placeholder Firebase credentials and will automatically fall back to local authentication. For production use, you'll need to set up a real Firebase project.

## Steps to Set Up Real Firebase Authentication

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name (e.g., "budget-app-pk")
4. Enable Google Analytics (optional)
5. Create the project

### 2. Enable Authentication
1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" provider
5. Save the changes

### 3. Configure Web App
1. In Firebase Console, go to "Project settings" (gear icon)
2. Scroll down to "Your apps" section
3. Click "Web" icon (</>) to add a web app
4. Enter app nickname (e.g., "Budget App Web")
5. Check "Also set up Firebase Hosting" (optional)
6. Click "Register app"
7. Copy the Firebase configuration object

### 4. Update Firebase Configuration
Replace the demo values in `lib/firebase_options.dart` with your real Firebase configuration:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'your-actual-api-key',
  appId: 'your-actual-app-id',
  messagingSenderId: 'your-actual-sender-id',
  projectId: 'your-actual-project-id',
  authDomain: 'your-project-id.firebaseapp.com',
  storageBucket: 'your-project-id.appspot.com',
  measurementId: 'your-actual-measurement-id',
);
```

### 5. Configure Firestore (Optional)
If you want to store user profiles in Firestore:
1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" for development
4. Select a location for your database
5. Click "Done"

### 6. Set Up Security Rules
For Firestore, update security rules to allow authenticated users:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 7. Test with Real Firebase
1. Update the configuration files
2. Run `flutter run -d chrome`
3. Test registration and sign-in
4. Check Firebase Console to see registered users

## Benefits of Using Real Firebase

### With Real Firebase:
- ✅ Cross-platform authentication (web, mobile)
- ✅ Password reset functionality
- ✅ Email verification
- ✅ User management in Firebase Console
- ✅ Secure cloud-based authentication
- ✅ Integration with other Firebase services

### With Local Authentication (Current):
- ✅ Works offline
- ✅ No external dependencies
- ✅ Fast authentication
- ❌ Limited to single device
- ❌ No password reset
- ❌ No cross-platform sync

## Environment-Specific Configuration

For different environments (development, staging, production), you can:

1. Create separate Firebase projects for each environment
2. Use environment variables or build configurations
3. Update `firebase_options.dart` accordingly

## Security Considerations

1. **Never commit real API keys to public repositories**
2. Use environment variables for sensitive configuration
3. Set up proper Firestore security rules
4. Enable App Check for additional security
5. Configure authorized domains in Firebase Console

## Troubleshooting

### Common Issues:
1. **CORS errors**: Ensure your domain is added to authorized domains in Firebase Console
2. **API key restrictions**: Check API key restrictions in Google Cloud Console
3. **Authentication errors**: Verify Email/Password provider is enabled
4. **Network errors**: Check internet connection and Firebase service status

### Debug Steps:
1. Check browser console for detailed error messages
2. Verify Firebase configuration values
3. Test with Firebase Console authentication simulator
4. Check Firebase Console logs for authentication attempts
