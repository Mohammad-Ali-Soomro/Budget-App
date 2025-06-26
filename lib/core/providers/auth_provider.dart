import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

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
    state = state.copyWith(isAuthenticated: AuthService.isLoggedIn);
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
      
      if (result != null) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
        );
        return true;
      }
      
      state = state.copyWith(
        isLoading: false,
        error: 'Registration failed',
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
      
      if (result != null) {
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
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
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
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
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
}
