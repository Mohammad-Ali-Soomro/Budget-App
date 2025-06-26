import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends ConsumerStatefulWidget {
  final Widget child;

  const MainScreen({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: PhosphorIcons.house(),
      activeIcon: PhosphorIcons.house(),
      label: 'Dashboard',
      route: '/dashboard',
    ),
    NavigationItem(
      icon: PhosphorIcons.arrowsLeftRight(),
      activeIcon: PhosphorIcons.arrowsLeftRight(),
      label: 'Transactions',
      route: '/transactions',
    ),
    NavigationItem(
      icon: PhosphorIcons.chartPie(),
      activeIcon: PhosphorIcons.chartPie(),
      label: 'Budgets',
      route: '/budgets',
    ),
    NavigationItem(
      icon: PhosphorIcons.wallet(),
      activeIcon: PhosphorIcons.wallet(),
      label: 'Accounts',
      route: '/accounts',
    ),
    NavigationItem(
      icon: PhosphorIcons.gear(),
      activeIcon: PhosphorIcons.gear(),
      label: 'Settings',
      route: '/settings',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.go(_navigationItems[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.colorScheme.surface,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: _navigationItems.map((item) {
            final isSelected = _navigationItems.indexOf(item) == _selectedIndex;
            return BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: 24,
                ),
              ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
      floatingActionButton: _selectedIndex == 1 // Show FAB only on transactions page
          ? FloatingActionButton(
              onPressed: () => context.push('/transactions/add'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              child: Icon(PhosphorIcons.plus()),
            )
          : null,
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
