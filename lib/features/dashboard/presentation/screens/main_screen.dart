import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/config/theme_config.dart';
import 'dashboard_screen.dart';
import '../../../transactions/presentation/screens/transactions_screen.dart';
import '../../../budgets/presentation/screens/budgets_screen.dart';
import '../../../goals/presentation/screens/goals_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../transactions/presentation/screens/add_transaction_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final theme = Theme.of(context);

    final screens = [
      const DashboardScreen(),
      const TransactionsScreen(),
      const BudgetsScreen(),
      const GoalsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            ref.read(navigationIndexProvider.notifier).setIndex(index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.colorScheme.surface,
          selectedItemColor: ThemeConfig.primaryGreen,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          items: [
            BottomNavigationBarItem(
              icon: PhosphorIcon(
                currentIndex == 0 ? PhosphorIcons.house(PhosphorIconsStyle.fill) : PhosphorIcons.house(),
                size: 24,
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: PhosphorIcon(
                currentIndex == 1 ? PhosphorIcons.listBullets(PhosphorIconsStyle.fill) : PhosphorIcons.listBullets(),
                size: 24,
              ),
              label: 'Transactions',
            ),
            BottomNavigationBarItem(
              icon: PhosphorIcon(
                currentIndex == 2 ? PhosphorIcons.chartPie(PhosphorIconsStyle.fill) : PhosphorIcons.chartPie(),
                size: 24,
              ),
              label: 'Budgets',
            ),
            BottomNavigationBarItem(
              icon: PhosphorIcon(
                currentIndex == 3 ? PhosphorIcons.target(PhosphorIconsStyle.fill) : PhosphorIcons.target(),
                size: 24,
              ),
              label: 'Goals',
            ),
            BottomNavigationBarItem(
              icon: PhosphorIcon(
                currentIndex == 4 ? PhosphorIcons.gear(PhosphorIconsStyle.fill) : PhosphorIcons.gear(),
                size: 24,
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
      floatingActionButton: currentIndex == 1 // Show FAB only on transactions screen
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddTransactionScreen(),
                  ),
                );
              },
              backgroundColor: ThemeConfig.primaryGreen,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add, size: 28),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
