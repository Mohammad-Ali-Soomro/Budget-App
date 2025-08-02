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

    test('AuthState should have proper initial values', () {
      final authState = container.read(authControllerProvider);

      expect(authState.isAuthenticated, false);
      expect(authState.isLoading, false);
      expect(authState.error, null);
    });
  });
}
