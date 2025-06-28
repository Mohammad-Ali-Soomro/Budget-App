import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/transactions/providers/transaction_providers.dart';
import '../../features/accounts/providers/account_providers.dart';
import '../../features/budgets/providers/budget_providers.dart';
import '../../features/categories/providers/category_providers.dart';

/// Central refresh provider to coordinate data synchronization across the app
final refreshCoordinatorProvider = Provider<RefreshCoordinator>((ref) {
  return RefreshCoordinator(ref);
});

class RefreshCoordinator {
  final Ref _ref;

  RefreshCoordinator(this._ref);

  /// Refresh all data providers
  Future<void> refreshAll() async {
    await Future.wait([
      refreshTransactions(),
      refreshAccounts(),
      refreshBudgets(),
      refreshCategories(),
    ]);
  }

  /// Refresh only transaction-related data
  Future<void> refreshTransactions() async {
    _ref.read(transactionsProvider.notifier).refresh();
    // Invalidate derived providers
    _ref.invalidate(recentTransactionsProvider);
    _ref.invalidate(weeklyExpensesProvider);
    _ref.invalidate(monthlyExpensesProvider);
    _ref.invalidate(monthlyIncomeProvider);
  }

  /// Refresh only account-related data
  Future<void> refreshAccounts() async {
    _ref.read(accountsProvider.notifier).refresh();
    // Invalidate derived providers
    _ref.invalidate(totalBalanceProvider);
    _ref.invalidate(realTimeBalanceProvider);
  }

  /// Refresh only budget-related data
  Future<void> refreshBudgets() async {
    _ref.read(budgetsProvider.notifier).refresh();
    // Invalidate derived providers
    _ref.invalidate(activeBudgetsProvider);
    _ref.invalidate(budgetProgressProvider);
    _ref.invalidate(realTimeBudgetSpendingProvider);
    _ref.invalidate(realTimeBudgetStatusProvider);
  }

  /// Refresh only category-related data
  Future<void> refreshCategories() async {
    _ref.read(categoriesProvider.notifier).refresh();
    // Invalidate derived providers
    _ref.invalidate(parentCategoriesProvider);
    _ref.invalidate(expenseCategoriesProvider);
    _ref.invalidate(incomeCategoriesProvider);
  }

  /// Refresh data after transaction changes
  Future<void> refreshAfterTransactionChange() async {
    await Future.wait([
      refreshTransactions(),
      refreshAccounts(),
      refreshBudgets(),
    ]);
  }

  /// Refresh data after account changes
  Future<void> refreshAfterAccountChange() async {
    await Future.wait([
      refreshAccounts(),
      refreshTransactions(), // Transactions depend on accounts
    ]);
  }

  /// Refresh data after budget changes
  Future<void> refreshAfterBudgetChange() async {
    await Future.wait([
      refreshBudgets(),
      refreshTransactions(), // Budget calculations depend on transactions
    ]);
  }

  /// Refresh data after category changes
  Future<void> refreshAfterCategoryChange() async {
    await Future.wait([
      refreshCategories(),
      refreshTransactions(), // Transactions depend on categories
      refreshBudgets(), // Budgets depend on categories
    ]);
  }
}

/// Provider to track last refresh time for debugging
final lastRefreshTimeProvider = StateProvider<DateTime?>((ref) => null);

/// Provider to track refresh status
final refreshStatusProvider = StateProvider<RefreshStatus>((ref) => RefreshStatus.idle);

enum RefreshStatus {
  idle,
  refreshing,
  completed,
  error,
}

/// Auto-refresh provider that refreshes data periodically
final autoRefreshProvider = StreamProvider<int>((ref) {
  // Auto-refresh every 30 seconds when app is active
  return Stream.periodic(const Duration(seconds: 30), (count) {
    final coordinator = ref.read(refreshCoordinatorProvider);
    coordinator.refreshAll().then((_) {
      ref.read(lastRefreshTimeProvider.notifier).state = DateTime.now();
      ref.read(refreshStatusProvider.notifier).state = RefreshStatus.completed;
    }).catchError((error) {
      ref.read(refreshStatusProvider.notifier).state = RefreshStatus.error;
    });
    return count;
  });
});

/// Provider for manual refresh trigger
final manualRefreshProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    ref.read(refreshStatusProvider.notifier).state = RefreshStatus.refreshing;
    
    try {
      final coordinator = ref.read(refreshCoordinatorProvider);
      await coordinator.refreshAll();
      
      ref.read(lastRefreshTimeProvider.notifier).state = DateTime.now();
      ref.read(refreshStatusProvider.notifier).state = RefreshStatus.completed;
    } catch (error) {
      ref.read(refreshStatusProvider.notifier).state = RefreshStatus.error;
      rethrow;
    }
  };
});

/// Provider to check if data is stale (older than 5 minutes)
final isDataStaleProvider = Provider<bool>((ref) {
  final lastRefresh = ref.watch(lastRefreshTimeProvider);
  if (lastRefresh == null) return true;
  
  final now = DateTime.now();
  final difference = now.difference(lastRefresh);
  
  return difference.inMinutes > 5;
});

/// Provider for data freshness indicator
final dataFreshnessProvider = Provider<DataFreshness>((ref) {
  final lastRefresh = ref.watch(lastRefreshTimeProvider);
  if (lastRefresh == null) return DataFreshness.unknown;
  
  final now = DateTime.now();
  final difference = now.difference(lastRefresh);
  
  if (difference.inSeconds < 30) {
    return DataFreshness.fresh;
  } else if (difference.inMinutes < 2) {
    return DataFreshness.recent;
  } else if (difference.inMinutes < 5) {
    return DataFreshness.stale;
  } else {
    return DataFreshness.veryStale;
  }
});

enum DataFreshness {
  fresh,
  recent,
  stale,
  veryStale,
  unknown,
}

/// Provider for connection status monitoring
final connectionStatusProvider = StateProvider<ConnectionStatus>((ref) => ConnectionStatus.connected);

enum ConnectionStatus {
  connected,
  disconnected,
  reconnecting,
}

/// Provider that handles offline/online state changes
final offlineDataSyncProvider = Provider<void>((ref) {
  final connectionStatus = ref.watch(connectionStatusProvider);
  
  // When connection is restored, refresh all data
  ref.listen(connectionStatusProvider, (previous, next) {
    if (previous == ConnectionStatus.disconnected && 
        next == ConnectionStatus.connected) {
      final coordinator = ref.read(refreshCoordinatorProvider);
      coordinator.refreshAll();
    }
  });
});
