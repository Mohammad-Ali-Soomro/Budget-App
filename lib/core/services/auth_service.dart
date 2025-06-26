import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_profile.dart';

class AuthService {
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static final LocalAuthentication _localAuth = LocalAuthentication();

  // Initialize Firebase services
  static void _initializeServices() {
    try {
      if (Firebase.apps.isNotEmpty) {
        _auth ??= FirebaseAuth.instance;
        _firestore ??= FirebaseFirestore.instance;
      }
    } catch (e) {
      // Firebase not available, services will remain null
    }
  }

  // Get current user
  static User? get currentUser {
    _initializeServices();
    return _auth?.currentUser;
  }

  // Auth state stream
  static Stream<User?> get authStateChanges {
    _initializeServices();
    return _auth?.authStateChanges() ?? Stream.value(null);
  }

  // Check if user is logged in
  static bool get isLoggedIn {
    _initializeServices();
    return _auth?.currentUser != null;
  }

  // Register with email and password
  static Future<UserCredential?> registerWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    _initializeServices();
    if (_auth == null) {
      throw Exception('Firebase Auth not available');
    }

    try {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user profile in Firestore
        await _createUserProfile(
          uid: credential.user!.uid,
          email: email,
          fullName: fullName,
          phoneNumber: phoneNumber,
        );

        // Update display name
        await credential.user!.updateDisplayName(fullName);

        // Store credentials for biometric auth
        await _storage.write(key: 'user_email', value: email);
        await _storage.write(key: 'user_password', value: password);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  // Sign in with email and password
  static Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    _initializeServices();
    if (_auth == null) {
      throw Exception('Firebase Auth not available');
    }

    try {
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store credentials securely for biometric login
      await _storage.write(key: 'user_email', value: email);
      await _storage.write(key: 'user_password', value: password);

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  // Sign in with biometrics
  static Future<UserCredential?> signInWithBiometrics() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        throw Exception('Biometric authentication not available');
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your budget app',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        final email = await _storage.read(key: 'user_email');
        final password = await _storage.read(key: 'user_password');
        
        if (email != null && password != null) {
          return await signInWithEmailPassword(
            email: email,
            password: password,
          );
        }
      }
      
      return null;
    } catch (e) {
      throw Exception('Biometric authentication failed: $e');
    }
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    _initializeServices();
    if (_auth == null) {
      throw Exception('Firebase Auth not available');
    }

    try {
      await _auth!.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  // Send email verification
  static Future<void> sendEmailVerification() async {
    _initializeServices();
    if (_auth == null || currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      await currentUser!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  // Check if email is verified
  static bool get isEmailVerified {
    _initializeServices();
    return currentUser?.emailVerified ?? false;
  }

  // Reload user to get updated verification status
  static Future<void> reloadUser() async {
    _initializeServices();
    if (_auth == null || currentUser == null) return;

    try {
      await currentUser!.reload();
    } catch (e) {
      // Ignore reload errors
    }
  }

  // Sign out
  static Future<void> signOut() async {
    _initializeServices();
    if (_auth != null) {
      await _auth!.signOut();
    }
    // Clear stored credentials
    await _storage.delete(key: 'user_email');
    await _storage.delete(key: 'user_password');
  }

  // Get user profile
  static Future<UserProfile?> getUserProfile() async {
    _initializeServices();
    if (currentUser == null || _firestore == null) return null;

    try {
      final doc = await _firestore!
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (doc.exists) {
        return UserProfile.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Update user profile
  static Future<void> updateUserProfile(UserProfile profile) async {
    _initializeServices();
    if (currentUser == null || _firestore == null) return;

    try {
      await _firestore!
          .collection('users')
          .doc(currentUser!.uid)
          .update(profile.toMap());
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Create user profile in Firestore
  static Future<void> _createUserProfile({
    required String uid,
    required String email,
    required String fullName,
    required String phoneNumber,
  }) async {
    _initializeServices();
    if (_firestore == null) return;

    final profile = UserProfile(
      uid: uid,
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      createdAt: DateTime.now(),
    );

    await _firestore!
        .collection('users')
        .doc(uid)
        .set(profile.toMap());
  }

  // Handle Firebase Auth exceptions
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Signing in with Email and Password is not enabled.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }

  // Check if biometric authentication is available
  static Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return isAvailable && availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Enable biometric authentication
  static Future<bool> enableBiometricAuth() async {
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Enable biometric authentication for quick access',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return isAuthenticated;
    } catch (e) {
      return false;
    }
  }
}
