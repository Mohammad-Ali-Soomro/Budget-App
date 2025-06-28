import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/config/theme_config.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../accounts/providers/account_providers.dart';

class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accounts = ref.watch(accountsProvider);
    final currency = ref.watch(currencyProvider);
    final realTimeBalance = ref.watch(realTimeBalanceProvider);

    return accounts.when(
      data: (accountList) {
        return realTimeBalance.when(
          data: (totalBalance) {

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ThemeConfig.primaryGreen,
                ThemeConfig.primaryGreenDark,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: ThemeConfig.primaryGreen.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Balance',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$currency ${totalBalance.toStringAsFixed(0)}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        PhosphorIcons.wallet(),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Account breakdown
                Row(
                  children: [
                    Expanded(
                      child: _buildAccountSummary(
                        context,
                        'Cash',
                        accountList
                            .where((a) => a.type.name == 'cash')
                            .fold<double>(0.0, (sum, a) => sum + a.balance),
                        currency,
                        PhosphorIcons.money(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAccountSummary(
                        context,
                        'Bank',
                        accountList
                            .where((a) => a.type.name == 'bank')
                            .fold<double>(0.0, (sum, a) => sum + a.balance),
                        currency,
                        PhosphorIcons.bank(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAccountSummary(
                        context,
                        'Mobile',
                        accountList
                            .where((a) => a.type.name == 'mobileWallet')
                            .fold<double>(0.0, (sum, a) => sum + a.balance),
                        currency,
                        PhosphorIcons.deviceMobile(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
          },
          loading: () => Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error loading balance',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: theme.colorScheme.error,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Error loading balance',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSummary(
    BuildContext context,
    String title,
    double amount,
    String currency,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$currency ${amount.toStringAsFixed(0)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
