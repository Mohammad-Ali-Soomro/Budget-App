import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/config/theme_config.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../accounts/providers/account_providers.dart';
import '../../../transactions/providers/transaction_providers.dart';
import '../../../budgets/providers/budget_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final currency = ref.watch(currencyProvider);
    final totalBalance = ref.watch(realTimeBalanceProvider);
    final monthlyIncome = ref.watch(monthlyIncomeProvider);
    final monthlyExpenses = ref.watch(monthlyExpensesProvider);
    final activeBudgets = ref.watch(activeBudgetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to edit profile
            },
            icon: Icon(PhosphorIcons.pencil()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Profile Picture
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: ThemeConfig.primaryGreen.withOpacity(0.1),
                          child: Icon(
                            PhosphorIcons.user(),
                            size: 48,
                            color: ThemeConfig.primaryGreen,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: ThemeConfig.primaryGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              PhosphorIcons.camera(),
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // User Info
                    Text(
                      user?.email ?? 'User',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      user?.email ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Quick Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(
                          context,
                          'Total Balance',
                          totalBalance.when(
                            data: (balance) => '$currency ${balance.toStringAsFixed(0)}',
                            loading: () => 'Loading...',
                            error: (_, __) => 'Error',
                          ),
                          PhosphorIcons.wallet(),
                          ThemeConfig.primaryGreen,
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey[300],
                        ),
                        _buildStatItem(
                          context,
                          'Active Budgets',
                          activeBudgets.when(
                            data: (budgets) => budgets.length.toString(),
                            loading: () => '...',
                            error: (_, __) => '0',
                          ),
                          PhosphorIcons.target(),
                          Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Financial Summary Section
            Text(
              'Financial Summary',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Monthly Overview Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    'Monthly Income',
                    monthlyIncome.when(
                      data: (income) => '$currency ${income.toStringAsFixed(0)}',
                      loading: () => 'Loading...',
                      error: (_, __) => 'Error',
                    ),
                    PhosphorIcons.trendUp(),
                    ThemeConfig.primaryGreen,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    'Monthly Expenses',
                    monthlyExpenses.when(
                      data: (expenses) => '$currency ${expenses.toStringAsFixed(0)}',
                      loading: () => 'Loading...',
                      error: (_, __) => 'Error',
                    ),
                    PhosphorIcons.trendDown(),
                    ThemeConfig.accentRed,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Account Management Section
            Text(
              'Account Management',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Card(
              child: Column(
                children: [
                  _buildSettingsTile(
                    context,
                    'Personal Information',
                    'Update your profile details',
                    PhosphorIcons.user(),
                    () {
                      // Navigate to personal info edit
                    },
                  ),
                  _buildSettingsTile(
                    context,
                    'Security Settings',
                    'Change password and security options',
                    PhosphorIcons.shield(),
                    () {
                      // Navigate to security settings
                    },
                  ),
                  _buildSettingsTile(
                    context,
                    'Notification Preferences',
                    'Manage your notification settings',
                    PhosphorIcons.bell(),
                    () {
                      // Navigate to notification settings
                    },
                  ),
                  _buildSettingsTile(
                    context,
                    'Currency & Language',
                    'Set your preferred currency and language',
                    PhosphorIcons.globe(),
                    () {
                      // Navigate to currency/language settings
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Data & Privacy Section
            Text(
              'Data & Privacy',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Card(
              child: Column(
                children: [
                  _buildSettingsTile(
                    context,
                    'Export Data',
                    'Download your financial data',
                    PhosphorIcons.download(),
                    () {
                      // Export data functionality
                    },
                  ),
                  _buildSettingsTile(
                    context,
                    'Backup & Sync',
                    'Manage data backup and synchronization',
                    PhosphorIcons.cloudArrowUp(),
                    () {
                      // Backup settings
                    },
                  ),
                  _buildSettingsTile(
                    context,
                    'Privacy Policy',
                    'Read our privacy policy',
                    PhosphorIcons.info(),
                    () {
                      // Show privacy policy
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIcons.signOut()),
                    const SizedBox(width: 8),
                    const Text('Sign Out'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ThemeConfig.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: ThemeConfig.primaryGreen,
          size: 20,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(
        PhosphorIcons.caretRight(),
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implement sign out logic
              // ref.read(authControllerProvider.notifier).signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}