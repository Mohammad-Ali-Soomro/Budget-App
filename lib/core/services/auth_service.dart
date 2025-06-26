import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:uuid/uuid.dart';

import '../../features/auth/data/models/user_model.dart';
import '../models/user_profile.dart';
import './hive_service.dart';

class AuthService {
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static bool _useLocalAuth = false;

  // Initialize Firebase services
  static void _initializeServices() {
    try {
      if (Firebase.apps.isNotEmpty) {
        _auth ??= FirebaseAuth.instance;
        _firestore ??= FirebaseFirestore.instance;
        _useLocalAuth = false;
      }
    } catch (e) {
      // Firebase not available, use local authentication
      _useLocalAuth = true;
    }
  }

  // Check if using local authentication
  static bool get isUsingLocalAuth => _useLocalAuth;

  // Get current user
  static User? get currentUser {
    _initializeServices();
    return _auth?.currentUser;
  }

  // Auth state stream
  static Stream<User?> get authStateChanges {
    _initializeServices();
    if (_useLocalAuth) {
      return _localAuthStateChanges();
    }
    return _auth?.authStateChanges() ?? Stream.value(null);
  }

  // Check if user is logged in
  static bool get isLoggedIn {
    _initializeServices();
    if (_useLocalAuth) {
      return _isLocalUserLoggedIn();
    }
    return _auth?.currentUser != null;
  }

  // Local auth state stream
  static Stream<User?> _localAuthStateChanges() async* {
    final userBox = HiveService.userBox;
    if (userBox.containsKey('current_user')) {
      yield _createMockUser(userBox.get('current_user'));
    } else {
      yield null;
    }
  }

  // Check if local user is logged in
  static bool _isLocalUserLoggedIn() {
    final userBox = HiveService.userBox;
    return userBox.containsKey('current_user');
  }

  // Create mock Firebase User for local authentication
  static User? _createMockUser(UserModel? userModel) {
    if (userModel == null) return null;
    // Return null for now - we'll handle this in the auth controller
    return null;
  }

  // Register with email and password
  static Future<UserCredential?> registerWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    _initializeServices();

    if (_useLocalAuth) {
      // Use local authentication with Hive
      return await _registerLocalUser(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
    }

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

    if (_useLocalAuth) {
      // Use local authentication with Hive
      return await _signInLocalUser(
        email: email,
        password: password,
      );
    }

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

    if (_useLocalAuth) {
      // Local sign out
      final userBox = HiveService.userBox;
      await userBox.delete('current_user');
    } else if (_auth != null) {
      await _auth!.signOut();
    }

    // Clear stored credentials
    await _storage.delete(key: 'user_email');
    await _storage.delete(key: 'user_password');
    await _storage.delete(key: 'user_password_hash');
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

  // Local authentication methods
  static Future<UserCredential?> _registerLocalUser({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      final userBox = HiveService.userBox;

      // Check if user already exists
      final existingUsers = userBox.values.where((user) => user.email == email);
      if (existingUsers.isNotEmpty) {
        throw Exception('An account already exists for this email.');
      }

      // Hash password for security
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();

      // Create user model
      final user = UserModel(
        id: const Uuid().v4(),
        name: fullName,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
      );

      // Store user in Hive with email as key and also as current user
      await userBox.put(email, user);
      await userBox.put('current_user', user);

      // Store hashed password securely with email-specific key
      await _storage.write(key: 'user_password_hash_$email', value: hashedPassword);
      await _storage.write(key: 'user_email', value: email);
      await _storage.write(key: 'user_password', value: password);

      // Return a mock UserCredential for compatibility
      return _createMockUserCredential(user);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<UserCredential?> _signInLocalUser({
    required String email,
    required String password,
  }) async {
    try {
      final userBox = HiveService.userBox;

      // Find user by email
      final user = userBox.get(email);
      if (user == null) {
        throw Exception('No user found for this email.');
      }

      // Verify password
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();
      final storedHash = await _storage.read(key: 'user_password_hash_$email');

      if (storedHash != hashedPassword) {
        throw Exception('Wrong password provided.');
      }

      // Store credentials for biometric auth
      await _storage.write(key: 'user_email', value: email);
      await _storage.write(key: 'user_password', value: password);

      // Set as current user
      await userBox.put('current_user', user);

      // Return a mock UserCredential for compatibility
      return _createMockUserCredential(user);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static UserCredential? _createMockUserCredential(UserModel user) {
    // This is a simplified mock for local authentication
    // In a real implementation, you might want to create a proper mock
    return null; // The calling code will check for null and handle accordingly
  }
}
