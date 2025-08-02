import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_app_pk/core/providers/auth_provider.dart';

void main() {
  group('Authentication State Management Tests', () {
    late ProviderContainer container;

    setUp(() {
      // Create a fresh provider container for each test
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('AuthController should start with unauthenticated state', () {
      final authState = container.read(authControllerProvider);

      expect(authState.isAuthenticated, false);
      expect(authState.isLoading, false);
      expect(authState.error, null);
    });

    test('AuthController should handle loading states correctly', () {
      final authController = container.read(authControllerProvider.notifier);

      // Initial state
      var authState = container.read(authControllerProvider);
      expect(authState.isLoading, false);

      // Clear error should work
      authController.clearError();
      authState = container.read(authControllerProvider);
      expect(authState.error, null);
    });

    test('User sign-in should log in the correct user', () async {
      final authController = container.read(authControllerProvider.notifier);
      
      // First register a user
      await authController.register(
        email: 'test2@example.com',
        password: 'password123',
        fullName: 'Test User 2',
        phoneNumber: '1234567890',
      );
      
      // Ensure user is not logged in after registration
      expect(AuthService.isLoggedIn, false);
      
      // Now sign in
      final success = await authController.signIn(
        email: 'test2@example.com',
        password: 'password123',
      );
      
      expect(success, true);
      expect(AuthService.isLoggedIn, true);
      expect(container.read(authControllerProvider).isAuthenticated, true);
      
      // Verify correct user is logged in
      final currentUser = AuthService.getCurrentLocalUser();
      expect(currentUser, isNotNull);
      expect(currentUser!.email, 'test2@example.com');
      expect(currentUser.name, 'Test User 2');
    });

    test('Account switching should work correctly', () async {
      final authController = container.read(authControllerProvider.notifier);
      
      // Register first user
      await authController.register(
        email: 'user1@example.com',
        password: 'password123',
        fullName: 'User One',
        phoneNumber: '1111111111',
      );
      
      // Register second user
      await authController.register(
        email: 'user2@example.com',
        password: 'password123',
        fullName: 'User Two',
        phoneNumber: '2222222222',
      );
      
      // Sign in as first user
      await authController.signIn(
        email: 'user1@example.com',
        password: 'password123',
      );
      
      var currentUser = AuthService.getCurrentLocalUser();
      expect(currentUser!.email, 'user1@example.com');
      expect(currentUser.name, 'User One');
      
      // Sign out
      await authController.signOut();
      expect(AuthService.isLoggedIn, false);
      
      // Sign in as second user
      await authController.signIn(
        email: 'user2@example.com',
        password: 'password123',
      );
      
      currentUser = AuthService.getCurrentLocalUser();
      expect(currentUser!.email, 'user2@example.com');
      expect(currentUser.name, 'User Two');
    });

    test('New user registration should not interfere with existing users', () async {
      final authController = container.read(authControllerProvider.notifier);
      
      // Register and sign in first user
      await authController.register(
        email: 'existing@example.com',
        password: 'password123',
        fullName: 'Existing User',
        phoneNumber: '1111111111',
      );
      
      await authController.signIn(
        email: 'existing@example.com',
        password: 'password123',
      );
      
      var currentUser = AuthService.getCurrentLocalUser();
      expect(currentUser!.email, 'existing@example.com');
      
      // Sign out
      await authController.signOut();
      
      // Register a new user
      await authController.register(
        email: 'newuser@example.com',
        password: 'password123',
        fullName: 'New User',
        phoneNumber: '2222222222',
      );
      
      // New user should NOT be logged in
      expect(AuthService.isLoggedIn, false);
      
      // Sign in as new user
      await authController.signIn(
        email: 'newuser@example.com',
        password: 'password123',
      );
      
      currentUser = AuthService.getCurrentLocalUser();
      expect(currentUser!.email, 'newuser@example.com');
      expect(currentUser.name, 'New User');
      
      // Verify both users exist in storage
      final userBox = HiveService.userBox;
      expect(userBox.containsKey('existing@example.com'), true);
      expect(userBox.containsKey('newuser@example.com'), true);
    });
  });
}
