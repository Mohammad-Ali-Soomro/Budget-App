import 'package:flutter/foundation.dart';
import '../services/hive_service.dart';
import '../services/auth_service.dart';

/// Debug utilities for authentication testing
class AuthDebugUtils {
  /// Clear all authentication data (for testing purposes only)
  static Future<void> clearAllAuthData() async {
    if (!kDebugMode) {
      debugPrint('clearAllAuthData can only be called in debug mode');
      return;
    }

    try {
      debugPrint('Clearing all authentication data...');
      
      // Sign out first
      await AuthService.signOut();
      
      // Clear Hive user data
      final userBox = HiveService.userBox;
      await userBox.clear();
      
      debugPrint('All authentication data cleared successfully');
    } catch (e) {
      debugPrint('Error clearing authentication data: $e');
    }
  }

  /// List all stored users (for debugging)
  static void listStoredUsers() {
    if (!kDebugMode) {
      debugPrint('listStoredUsers can only be called in debug mode');
      return;
    }

    try {
      final userBox = HiveService.userBox;
      debugPrint('Stored users:');
      debugPrint('Total users: ${userBox.length}');
      
      for (final key in userBox.keys) {
        final user = userBox.get(key);
        if (user != null) {
          debugPrint('Key: $key, User: ${user.email} (${user.name})');
        } else {
          debugPrint('Key: $key, User: null');
        }
      }
    } catch (e) {
      debugPrint('Error listing stored users: $e');
    }
  }

  /// Check authentication status (for debugging)
  static void checkAuthStatus() {
    if (!kDebugMode) {
      debugPrint('checkAuthStatus can only be called in debug mode');
      return;
    }

    try {
      final isLoggedIn = AuthService.isLoggedIn;
      final isUsingLocal = AuthService.isUsingLocalAuth;
      
      debugPrint('Authentication Status:');
      debugPrint('Is logged in: $isLoggedIn');
      debugPrint('Using local auth: $isUsingLocal');
      
      if (isUsingLocal) {
        final userBox = HiveService.userBox;
        final currentUser = userBox.get('current_user');
        debugPrint('Current user: ${currentUser?.email ?? 'none'}');
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
    }
  }
}
