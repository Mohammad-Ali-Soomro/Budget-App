import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/dashboard/presentation/screens/main_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import '../../features/transactions/presentation/screens/add_transaction_screen.dart';
import '../../features/budgets/presentation/screens/budgets_screen.dart';
import '../../features/accounts/presentation/screens/accounts_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.when(
        data: (user) => user != null,
        loading: () => false,
        error: (_, __) => false,
      );

      final isOnAuthPage = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/forgot-password');

      final isOnSplashOrOnboarding = state.matchedLocation == '/splash' ||
          state.matchedLocation == '/onboarding';

      // If user is logged in and on auth page, redirect to dashboard
      if (isLoggedIn && isOnAuthPage) {
        return '/dashboard';
      }

      // If user is not logged in and not on auth/splash/onboarding page, redirect to login
      if (!isLoggedIn && !isOnAuthPage && !isOnSplashOrOnboarding) {
        return '/login';
      }

      return null; // No redirect needed
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding Screen
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main App Routes
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const TransactionsScreen(),
            routes: [
              GoRoute(
                path: '/add',
                builder: (context, state) => const AddTransactionScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/budgets',
            builder: (context, state) => const BudgetsScreen(),
          ),
          GoRoute(
            path: '/accounts',
            builder: (context, state) => const AccountsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Custom page transitions
class SlideTransitionPage extends CustomTransitionPage<void> {
  const SlideTransitionPage({
    required super.child,
    required super.key,
    super.name,
    super.arguments,
    super.restorationId,
  }) : super(
          transitionsBuilder: _slideTransitionsBuilder,
          transitionDuration: const Duration(milliseconds: 300),
        );

  static Widget _slideTransitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOut)),
      ),
      child: child,
    );
  }
}

class FadeTransitionPage extends CustomTransitionPage<void> {
  const FadeTransitionPage({
    required super.child,
    required super.key,
    super.name,
    super.arguments,
    super.restorationId,
  }) : super(
          transitionsBuilder: _fadeTransitionsBuilder,
          transitionDuration: const Duration(milliseconds: 300),
        );

  static Widget _fadeTransitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation.drive(
        CurveTween(curve: Curves.easeInOut),
      ),
      child: child,
    );
  }
}
