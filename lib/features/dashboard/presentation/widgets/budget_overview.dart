import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/config/theme_config.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../budgets/providers/budget_providers.dart';
import '../../../categories/providers/category_providers.dart';

class BudgetOverview extends ConsumerWidget {
  const BudgetOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeBudgets = ref.watch(activeBudgetsProvider);
    final categories = ref.watch(categoriesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budget Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(navigationIndexProvider.notifier).setIndex(2);
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            activeBudgets.when(
              data: (budgets) {
                if (budgets.isEmpty) {
                  return _buildEmptyState(context);
                }

                return Column(
                  children: budgets.take(3).map((budget) {
                    return categories.when(
                      data: (categoryList) {
                        final category = categoryList.firstWhere(
                          (c) => c.id == budget.categoryId,
                          orElse: () => categoryList.first,
                        );

                        // Get real-time spending data
                        final realTimeSpending = ref.watch(realTimeBudgetSpendingProvider(budget.id));
                        final budgetStatus = ref.watch(realTimeBudgetStatusProvider(budget.id));
                        final percentage = budget.amount > 0 ? (realTimeSpending / budget.amount).clamp(0.0, 1.0) : 0.0;

                        return _BudgetItem(
                          categoryName: category.name,
                          categoryIcon: category.icon,
                          spent: realTimeSpending,
                          total: budget.amount,
                          percentage: percentage,
                          isExceeded: budgetStatus == BudgetStatus.exceeded,
                          isNearLimit: budgetStatus == BudgetStatus.nearLimit,
                        );
                      },
                      loading: () => _BudgetItem(
                        categoryName: 'Loading...',
                        categoryIcon: '💰',
                        spent: budget.spent,
                        total: budget.amount,
                        percentage: budget.percentage,
                        isExceeded: budget.isExceeded,
                        isNearLimit: budget.isNearLimit,
                      ),
                      error: (_, __) => _BudgetItem(
                        categoryName: 'Unknown',
                        categoryIcon: '💰',
                        spent: budget.spent,
                        total: budget.amount,
                        percentage: budget.percentage,
                        isExceeded: budget.isExceeded,
                        isNearLimit: budget.isNearLimit,
                      ),
                    );
                  }).toList(),
                );
              },
              loading: _buildLoadingState,
              error: (error, stack) => _buildErrorState(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            PhosphorIcons.chartPie(),
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No budgets set',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first budget to track spending',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(2, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading budgets',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetItem extends StatelessWidget {

  const _BudgetItem({
    required this.categoryName,
    required this.categoryIcon,
    required this.spent,
    required this.total,
    required this.percentage,
    required this.isExceeded,
    required this.isNearLimit,
  });
  final String categoryName;
  final String categoryIcon;
  final double spent;
  final double total;
  final double percentage;
  final bool isExceeded;
  final bool isNearLimit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color progressColor;
    if (isExceeded) {
      progressColor = ThemeConfig.accentRed;
    } else if (isNearLimit) {
      progressColor = ThemeConfig.accentYellow;
    } else {
      progressColor = ThemeConfig.primaryGreen;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              // Category Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    categoryIcon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          categoryName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Rs. ${spent.toStringAsFixed(0)} / Rs. ${total.toStringAsFixed(0)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Progress Bar
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: percentage.clamp(0.0, 1.0),
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: progressColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Percentage
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(percentage * 100).toStringAsFixed(0)}% used',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: progressColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isExceeded)
                          Text(
                            'Exceeded!',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: ThemeConfig.accentRed,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else if (isNearLimit)
                          Text(
                            'Near limit',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: ThemeConfig.accentYellow,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
