import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/config/theme_config.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/refresh_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_transactions.dart';
import '../widgets/expense_chart.dart';
import '../widgets/budget_overview.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final refreshStatus = ref.watch(refreshStatusProvider);
    final dataFreshness = ref.watch(dataFreshnessProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final manualRefresh = ref.read(manualRefreshProvider);
            await manualRefresh();
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: ThemeConfig.primaryGreen,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good ${_getGreeting()}!',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        user?.name ?? 'User',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                ),
                actions: [
                  // Data freshness indicator
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getDataFreshnessColor(dataFreshness).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getDataFreshnessColor(dataFreshness),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getDataFreshnessIcon(dataFreshness),
                              size: 12,
                              color: _getDataFreshnessColor(dataFreshness),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getDataFreshnessText(dataFreshness),
                              style: TextStyle(
                                fontSize: 10,
                                color: _getDataFreshnessColor(dataFreshness),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Show notifications
                    },
                    icon: const Icon(Icons.notifications_outlined),
                  ),
                  IconButton(
                    onPressed: () {
                      // Show profile
                    },
                    icon: const Icon(Icons.account_circle_outlined),
                  ),
                ],
              ),

              // Dashboard Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Balance Card
                    const BalanceCard(),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    const QuickActions(),
                    
                    const SizedBox(height: 24),
                    
                    // Expense Chart
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Spending Overview',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Navigate to detailed analytics
                                  },
                                  child: const Text('View All'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const ExpenseChart(),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Budget Overview
                    const BudgetOverview(),
                    
                    const SizedBox(height: 24),
                    
                    // Recent Transactions
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recent Transactions',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref.read(navigationIndexProvider.notifier).setIndex(1);
                                  },
                                  child: const Text('View All'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const RecentTransactions(),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Financial Tips Card
                    Card(
                      color: ThemeConfig.primaryGreenLight.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  PhosphorIcons.lightbulb(),
                                  color: ThemeConfig.primaryGreen,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Financial Tip',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: ThemeConfig.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _getFinancialTip(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 100), // Extra space for FAB
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  String _getFinancialTip() {
    final tips = [
      'Try the 50/30/20 rule: 50% for needs, 30% for wants, and 20% for savings.',
      'Track your expenses daily to identify spending patterns and areas for improvement.',
      'Set up automatic transfers to your savings account to build wealth consistently.',
      "Review your subscriptions monthly and cancel those you don't actively use.",
      'Consider using cash for discretionary spending to avoid overspending.',
      'Build an emergency fund covering 3-6 months of your essential expenses.',
    ];
    
    final index = DateTime.now().day % tips.length;
    return tips[index];
  }

  Color _getDataFreshnessColor(DataFreshness freshness) {
    switch (freshness) {
      case DataFreshness.fresh:
        return ThemeConfig.primaryGreen;
      case DataFreshness.recent:
        return Colors.blue;
      case DataFreshness.stale:
        return Colors.orange;
      case DataFreshness.veryStale:
        return ThemeConfig.accentRed;
      case DataFreshness.unknown:
        return Colors.grey;
    }
  }

  IconData _getDataFreshnessIcon(DataFreshness freshness) {
    switch (freshness) {
      case DataFreshness.fresh:
        return Icons.check_circle;
      case DataFreshness.recent:
        return Icons.schedule;
      case DataFreshness.stale:
        return Icons.warning;
      case DataFreshness.veryStale:
        return Icons.error;
      case DataFreshness.unknown:
        return Icons.help;
    }
  }

  String _getDataFreshnessText(DataFreshness freshness) {
    switch (freshness) {
      case DataFreshness.fresh:
        return 'Live';
      case DataFreshness.recent:
        return 'Recent';
      case DataFreshness.stale:
        return 'Stale';
      case DataFreshness.veryStale:
        return 'Old';
      case DataFreshness.unknown:
        return 'Unknown';
    }
  }
}
