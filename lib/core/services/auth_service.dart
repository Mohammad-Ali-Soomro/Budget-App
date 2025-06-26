import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../models/user_profile.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static final LocalAuthentication _localAuth = LocalAuthentication();

  // Get current user
  static User? get currentUser => _auth.currentUser;
  
  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is logged in
  static bool get isLoggedIn => _auth.currentUser != null;

  // Register with email and password
  static Future<UserCredential?> registerWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
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
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  static Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Store credentials securely for biometric login
      await _storage.write(key: 'user_email', value: email);
      await _storage.write(key: 'user_password', value: password);
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
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
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
    // Clear stored credentials
    await _storage.delete(key: 'user_email');
    await _storage.delete(key: 'user_password');
  }

  // Get user profile
  static Future<UserProfile?> getUserProfile() async {
    if (currentUser == null) return null;
    
    try {
      final doc = await _firestore
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
    if (currentUser == null) return;
    
    try {
      await _firestore
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
    final profile = UserProfile(
      uid: uid,
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      createdAt: DateTime.now(),
      currency: 'PKR',
      language: 'English',
      isDarkMode: false,
    );

    await _firestore
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
