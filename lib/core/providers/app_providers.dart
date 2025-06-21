import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/hive_service.dart';
import '../../features/auth/data/models/user_model.dart';

// Theme Mode Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('theme_mode') ?? 0;
    state = ThemeMode.values[themeModeIndex];
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = themeMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', themeMode.index);
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }
}

// Locale Provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    state = Locale(languageCode);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }
}

// First Time Provider
final isFirstTimeProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('is_first_time') ?? true;
});

final setFirstTimeProvider = Provider<Future<void> Function(bool)>((ref) {
  return (bool isFirstTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_time', isFirstTime);
    ref.invalidate(isFirstTimeProvider);
  };
});

// Authentication State Provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, bool>((ref) {
  return AuthStateNotifier();
});

class AuthStateNotifier extends StateNotifier<bool> {
  AuthStateNotifier() : super(false) {
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final userBox = HiveService.userBox;
    state = userBox.isNotEmpty;
  }

  Future<void> signIn(UserModel user) async {
    final userBox = HiveService.userBox;
    await userBox.put('current_user', user);
    state = true;
  }

  Future<void> signOut() async {
    final userBox = HiveService.userBox;
    await userBox.clear();
    state = false;
  }

  Future<void> updateUser(UserModel user) async {
    final userBox = HiveService.userBox;
    await userBox.put('current_user', user);
  }
}

// Current User Provider
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, UserModel?>((ref) {
  return CurrentUserNotifier();
});

class CurrentUserNotifier extends StateNotifier<UserModel?> {
  CurrentUserNotifier() : super(null) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final userBox = HiveService.userBox;
    state = userBox.get('current_user');
  }

  Future<void> updateUser(UserModel user) async {
    final userBox = HiveService.userBox;
    await userBox.put('current_user', user);
    state = user;
  }

  Future<void> clearUser() async {
    final userBox = HiveService.userBox;
    await userBox.clear();
    state = null;
  }
}

// Currency Provider
final currencyProvider = StateNotifierProvider<CurrencyNotifier, String>((ref) {
  return CurrencyNotifier(ref);
});

class CurrencyNotifier extends StateNotifier<String> {

  CurrencyNotifier(this.ref) : super('PKR') {
    _loadCurrency();
  }
  final Ref ref;

  Future<void> _loadCurrency() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      state = user.currency;
    } else {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getString('currency') ?? 'PKR';
    }
  }

  Future<void> setCurrency(String currency) async {
    state = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
    
    // Update user if logged in
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final updatedUser = user.copyWith(currency: currency);
      await ref.read(currentUserProvider.notifier).updateUser(updatedUser);
    }
  }
}

// Navigation Provider
final navigationIndexProvider = StateNotifierProvider<NavigationIndexNotifier, int>((ref) {
  return NavigationIndexNotifier();
});

class NavigationIndexNotifier extends StateNotifier<int> {
  NavigationIndexNotifier() : super(0);

  void setIndex(int index) {
    state = index;
  }
}

// Loading State Provider
final loadingProvider = StateNotifierProvider<LoadingNotifier, bool>((ref) {
  return LoadingNotifier();
});

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false);

  void setLoading(bool loading) {
    state = loading;
  }

  Future<T> withLoading<T>(Future<T> Function() operation) async {
    setLoading(true);
    try {
      return await operation();
    } finally {
      setLoading(false);
    }
  }
}

// Error Provider
final errorProvider = StateNotifierProvider<ErrorNotifier, String?>((ref) {
  return ErrorNotifier();
});

class ErrorNotifier extends StateNotifier<String?> {
  ErrorNotifier() : super(null);

  void setError(String? error) {
    state = error;
  }

  void clearError() {
    state = null;
  }
}

// Notification Settings Provider
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, Map<String, bool>>((ref) {
  return NotificationSettingsNotifier();
});

class NotificationSettingsNotifier extends StateNotifier<Map<String, bool>> {
  NotificationSettingsNotifier() : super({
    'budget_alerts': true,
    'bill_reminders': true,
    'goal_updates': true,
    'transaction_confirmations': false,
    'weekly_reports': true,
    'monthly_reports': true,
  }) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = <String, bool>{};
    
    for (final key in state.keys) {
      settings[key] = prefs.getBool('notification_$key') ?? state[key]!;
    }
    
    state = settings;
  }

  Future<void> updateSetting(String key, bool value) async {
    state = {...state, key: value};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_$key', value);
  }

  Future<void> enableAll() async {
    final newState = <String, bool>{};
    for (final key in state.keys) {
      newState[key] = true;
    }
    state = newState;
    
    final prefs = await SharedPreferences.getInstance();
    for (final key in state.keys) {
      await prefs.setBool('notification_$key', true);
    }
  }

  Future<void> disableAll() async {
    final newState = <String, bool>{};
    for (final key in state.keys) {
      newState[key] = false;
    }
    state = newState;
    
    final prefs = await SharedPreferences.getInstance();
    for (final key in state.keys) {
      await prefs.setBool('notification_$key', false);
    }
  }
}
