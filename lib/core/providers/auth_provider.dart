import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/hive_service.dart';
import '../../features/auth/data/models/user_model.dart';

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  return AuthService.authStateChanges;
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Local user provider for when Firebase User is not available
final localUserProvider = Provider<UserModel?>((ref) {
  try {
    final userBox = HiveService.userBox;
    if (userBox.containsKey('current_user')) {
      return userBox.get('current_user');
    }
    return null;
  } catch (e) {
    return null;
  }
});

// User profile provider
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  
  return await AuthService.getUserProfile();
});

// Auth controller
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});

// Auth state
class AuthState {
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth controller
class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(AuthState()) {
    _checkAuthState();
  }

  void _checkAuthState() {
    try {
      final isLoggedIn = AuthService.isLoggedIn;
      state = state.copyWith(isAuthenticated: isLoggedIn);
    } catch (e) {
      state = state.copyWith(isAuthenticated: false, error: 'Failed to check auth state');
    }
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await AuthService.registerWithEmailPassword(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );

      // Registration successful - but don't auto-login
      // User must explicitly sign in after registration
      if (result != null) {
        // Sign out immediately after registration to ensure clean state
        await AuthService.signOut();

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false, // Keep user logged out
        );
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error: 'Registration failed',
      );
      return false;
    } catch (e) {
      String errorMessage = _getErrorMessage(e.toString());
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return false;
    }
  }

  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await AuthService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      // For local auth, result might be null but sign-in could still be successful
      // Check if user is now logged in
      final isLoggedIn = AuthService.isLoggedIn;

      if (result != null || isLoggedIn) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
        );
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error: 'Sign in failed',
      );
      return false;
    } catch (e) {
      String errorMessage = _getErrorMessage(e.toString());
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return false;
    }
  }

  // Sign in with biometrics
  Future<bool> signInWithBiometrics() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await AuthService.signInWithBiometrics();
      
      if (result != null) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
        );
        return true;
      }
      
      state = state.copyWith(
        isLoading: false,
        error: 'Biometric authentication failed',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await AuthService.resetPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await AuthService.signOut();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
      );

      // Force a refresh of auth state
      _checkAuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow; // Re-throw to allow UI to handle the error
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Check biometric availability
  Future<bool> checkBiometricAvailability() async {
    return await AuthService.isBiometricAvailable();
  }

  // Enable biometric authentication
  Future<bool> enableBiometricAuth() async {
    return await AuthService.enableBiometricAuth();
  }

  // Helper method to convert technical errors to user-friendly messages
  String _getErrorMessage(String error) {
    // Clean up the error message first
    String cleanError = error;
    if (cleanError.startsWith('Exception: ')) {
      cleanError = cleanError.replaceFirst('Exception: ', '');
    }

    // Firebase-specific errors
    if (cleanError.contains('An account already exists for this email') ||
        cleanError.contains('email-already-in-use')) {
      return 'An account with this email already exists. Please try signing in instead.';
    } else if (cleanError.contains('No user found for this email') ||
               cleanError.contains('user-not-found')) {
      return 'No account found with this email. Please check your email or create a new account.';
    } else if (cleanError.contains('Wrong password provided') ||
               cleanError.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (cleanError.contains('weak-password')) {
      return 'The password is too weak. Please choose a stronger password (at least 6 characters).';
    } else if (cleanError.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (cleanError.contains('too-many-requests')) {
      return 'Too many failed attempts. Please try again later.';
    } else if (cleanError.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection and try again.';
    }
    // Local authentication errors
    else if (cleanError.contains('All fields are required')) {
      return 'Please fill in all required fields.';
    } else if (cleanError.contains('Please enter a valid email address')) {
      return 'Please enter a valid email address.';
    } else if (cleanError.contains('Password must be at least 6 characters long')) {
      return 'Password must be at least 6 characters long.';
    } else if (cleanError.contains('Authentication data not found')) {
      return 'Authentication data not found. Please register again.';
    } else if (cleanError.contains('Email and password are required')) {
      return 'Please enter both email and password.';
    }
    // Web-specific errors
    else if (cleanError.contains('Firebase Auth not available')) {
      return 'Authentication service is not available. Please try again later.';
    } else if (cleanError.contains('Firebase not initialized')) {
      return 'App is still loading. Please wait a moment and try again.';
    }
    // Generic fallback
    else {
      return cleanError.isNotEmpty ? cleanError : 'An unexpected error occurred. Please try again.';
    }
  }
}
