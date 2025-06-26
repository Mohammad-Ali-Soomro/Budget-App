import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../core/providers/app_providers.dart' as app_providers;
import '../../../../core/providers/auth_provider.dart' as auth_providers;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(app_providers.currentUserProvider);
    final themeMode = ref.watch(app_providers.themeModeProvider);
    final locale = ref.watch(app_providers.localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: ThemeConfig.primaryGreen.withOpacity(0.1),
                    child: Icon(
                      PhosphorIcons.user(),
                      size: 32,
                      color: ThemeConfig.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'User',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'user@example.com',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Navigate to profile edit
                    },
                    icon: Icon(PhosphorIcons.pencil()),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Preferences Section
          Text(
            'Preferences',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(PhosphorIcons.moon()),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      ref.read(app_providers.themeModeProvider.notifier).setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(PhosphorIcons.translate()),
                  title: const Text('Language'),
                  subtitle: Text(locale.languageCode == 'ur' ? 'اردو' : 'English'),
                  trailing: Icon(PhosphorIcons.caretRight()),
                  onTap: () {
                    _showLanguageDialog(context, ref);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(PhosphorIcons.currencyCircleDollar()),
                  title: const Text('Currency'),
                  subtitle: Text(user?.currency ?? 'PKR'),
                  trailing: Icon(PhosphorIcons.caretRight()),
                  onTap: () {
                    _showCurrencyDialog(context, ref);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(PhosphorIcons.bell()),
                  title: const Text('Notifications'),
                  trailing: Icon(PhosphorIcons.caretRight()),
                  onTap: () {
                    // Navigate to notification settings
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Data Section
          Text(
            'Data & Backup',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(PhosphorIcons.export()),
                  title: const Text('Export Data'),
                  subtitle: const Text('Export your financial data'),
                  trailing: Icon(PhosphorIcons.caretRight()),
                  onTap: () {
                    // Export data functionality
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(PhosphorIcons.downloadSimple()),
                  title: const Text('Import Data'),
                  subtitle: const Text('Import data from file'),
                  trailing: Icon(PhosphorIcons.caretRight()),
                  onTap: () {
                    // Import data functionality
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(PhosphorIcons.cloudArrowUp()),
                  title: const Text('Backup'),
                  subtitle: const Text('Backup your data to cloud'),
                  trailing: Icon(PhosphorIcons.caretRight()),
                  onTap: () {
                    // Backup functionality
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          Text(
            'About',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(PhosphorIcons.info()),
                  title: const Text('About App'),
                  subtitle: Text('Version ${AppConfig.appVersion}'),
                  trailing: Icon(PhosphorIcons.caretRight()),
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(PhosphorIcons.star()),
                  title: const Text('Rate App'),
                  subtitle: const Text('Rate us on Play Store'),
                  trailing: Icon(PhosphorIcons.caretRight()),
                  onTap: () {
                    // Rate app functionality
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(PhosphorIcons.envelope()),
                  title: const Text('Contact Support'),
                  subtitle: const Text('Get help and support'),
                  trailing: Icon(PhosphorIcons.caretRight()),
                  onTap: () {
                    // Contact support functionality
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Sign Out Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showSignOutDialog(context, ref);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConfig.accentRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign Out'),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                ref.read(app_providers.localeProvider.notifier).setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('اردو'),
              onTap: () {
                ref.read(app_providers.localeProvider.notifier).setLocale(const Locale('ur'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Pakistani Rupee (PKR)'),
              onTap: () {
                ref.read(app_providers.currencyProvider.notifier).setCurrency('PKR');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('US Dollar (USD)'),
              onTap: () {
                ref.read(app_providers.currencyProvider.notifier).setCurrency('USD');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConfig.appName,
      applicationVersion: AppConfig.appVersion,
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: ThemeConfig.primaryGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.account_balance_wallet,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const Text('A comprehensive budget management app designed specifically for Pakistani users.'),
        const SizedBox(height: 16),
        const Text('Features include expense tracking, budget planning, savings goals, and financial analytics with support for Pakistani payment methods.'),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                // Sign out using the auth controller
                await ref.read(auth_providers.authControllerProvider.notifier).signOut();

                // Also clear the app state provider
                await ref.read(app_providers.authStateProvider.notifier).signOut();

                // Close loading dialog
                if (context.mounted) {
                  Navigator.pop(context);

                  // Navigate to login screen
                  context.go('/login');
                }
              } catch (e) {
                // Close loading dialog
                if (context.mounted) {
                  Navigator.pop(context);

                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sign out failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
