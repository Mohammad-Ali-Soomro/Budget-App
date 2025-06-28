import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/hive_service.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/refresh_provider.dart';
import '../data/models/transaction_model.dart';
import '../../accounts/providers/account_providers.dart';
import '../../budgets/providers/budget_providers.dart';

// Transactions Provider
final transactionsProvider = StateNotifierProvider<TransactionsNotifier, AsyncValue<List<TransactionModel>>>((ref) {
  return TransactionsNotifier(ref);
});

class TransactionsNotifier extends StateNotifier<AsyncValue<List<TransactionModel>>> {
  final Ref _ref;

  TransactionsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadTransactions();

    // Listen to current user changes and refresh data
    _ref.listen(currentUserProvider, (previous, next) {
      if (previous?.id != next?.id) {
        _loadTransactions();
      }
    });
  }

  Future<void> _loadTransactions() async {
    try {
      final currentUser = _ref.read(currentUserProvider);
      if (currentUser == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final transactionBox = HiveService.transactionBox;
      final allTransactions = transactionBox.values.toList();

      // Filter transactions by current user ID with null safety
      final userTransactions = allTransactions
          .where((transaction) {
            // Handle legacy transactions that might not have userId field
            if (transaction.userId == null) {
              // Legacy transaction - for now, exclude to prevent data mixing
              // In a real app, you might want to migrate these or assign to a default user
              return false;
            }
            return transaction.userId == currentUser.id;
          })
          .toList();

      userTransactions.sort((a, b) => b.date.compareTo(a.date));

      // Debug logging
      print('Loaded ${userTransactions.length} transactions for user ${currentUser.id}');

      state = AsyncValue.data(userTransactions);
    } catch (error, stackTrace) {
      print('Error loading transactions: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final currentUser = _ref.read(currentUserProvider);
      if (currentUser == null) return;

      // Ensure transaction has correct user ID
      final userTransaction = transaction.copyWith(userId: currentUser.id);

      final transactionBox = HiveService.transactionBox;
      await transactionBox.put(userTransaction.id, userTransaction);

      // Update account balances based on transaction
      await _updateAccountBalances(userTransaction);

      // Update budget spending if applicable
      await _updateBudgetSpending(userTransaction);

      await _loadTransactions();

      // Use centralized refresh system
      final refreshCoordinator = _ref.read(refreshCoordinatorProvider);
      await refreshCoordinator.refreshAfterTransactionChange();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      final transactionBox = HiveService.transactionBox;

      // Get the old transaction to reverse its effects
      final oldTransaction = transactionBox.get(transaction.id);
      if (oldTransaction != null) {
        // Reverse the old transaction's account balance effects
        await _reverseAccountBalances(oldTransaction);
      }

      // Apply the new transaction
      await transactionBox.put(transaction.id, transaction);

      // Update account balances based on new transaction
      await _updateAccountBalances(transaction);

      // Update budget spending if applicable
      await _updateBudgetSpending(transaction);

      await _loadTransactions();

      // Use centralized refresh system
      final refreshCoordinator = _ref.read(refreshCoordinatorProvider);
      await refreshCoordinator.refreshAfterTransactionChange();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      final transactionBox = HiveService.transactionBox;

      // Get the transaction to reverse its effects
      final transaction = transactionBox.get(transactionId);
      if (transaction != null) {
        // Reverse the transaction's account balance effects
        await _reverseAccountBalances(transaction);

        // Update budget spending if applicable
        await _updateBudgetSpending(transaction);
      }

      await transactionBox.delete(transactionId);
      await _loadTransactions();

      // Use centralized refresh system
      final refreshCoordinator = _ref.read(refreshCoordinatorProvider);
      await refreshCoordinator.refreshAfterTransactionChange();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void refresh() {
    _loadTransactions();
  }

  // Helper method to update account balances when transactions change
  Future<void> _updateAccountBalances(TransactionModel transaction) async {
    try {
      final accountsNotifier = _ref.read(accountsProvider.notifier);

      if (transaction.type == TransactionType.income) {
        // Add to account balance for income
        await accountsNotifier.adjustAccountBalance(transaction.accountId, transaction.amount);
      } else if (transaction.type == TransactionType.expense) {
        // Subtract from account balance for expense
        await accountsNotifier.adjustAccountBalance(transaction.accountId, -transaction.amount);
      } else if (transaction.type == TransactionType.transfer && transaction.toAccountId != null) {
        // Transfer: subtract from source account, add to destination account
        await accountsNotifier.adjustAccountBalance(transaction.accountId, -transaction.amount);
        await accountsNotifier.adjustAccountBalance(transaction.toAccountId!, transaction.amount);
      }
    } catch (error) {
      // Log error but don't fail the transaction
      print('Error updating account balances: $error');
    }
  }

  // Helper method to reverse account balance changes when transactions are updated/deleted
  Future<void> _reverseAccountBalances(TransactionModel transaction) async {
    try {
      final accountsNotifier = _ref.read(accountsProvider.notifier);

      if (transaction.type == TransactionType.income) {
        // Reverse income: subtract from account balance
        await accountsNotifier.adjustAccountBalance(transaction.accountId, -transaction.amount);
      } else if (transaction.type == TransactionType.expense) {
        // Reverse expense: add back to account balance
        await accountsNotifier.adjustAccountBalance(transaction.accountId, transaction.amount);
      } else if (transaction.type == TransactionType.transfer && transaction.toAccountId != null) {
        // Reverse transfer: add back to source account, subtract from destination account
        await accountsNotifier.adjustAccountBalance(transaction.accountId, transaction.amount);
        await accountsNotifier.adjustAccountBalance(transaction.toAccountId!, -transaction.amount);
      }
    } catch (error) {
      // Log error but don't fail the transaction
      print('Error reversing account balances: $error');
    }
  }

  // Helper method to update budget spending when transactions change
  Future<void> _updateBudgetSpending(TransactionModel transaction) async {
    try {
      if (transaction.type == TransactionType.expense) {
        final budgetsNotifier = _ref.read(budgetsProvider.notifier);
        // The budget provider will automatically recalculate spending based on transactions
        budgetsNotifier.refresh();
      }
    } catch (error) {
      // Log error but don't fail the transaction
      print('Error updating budget spending: $error');
    }
  }
}

// Recent Transactions Provider (last 10)
final recentTransactionsProvider = Provider<AsyncValue<List<TransactionModel>>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  return transactions.when(
    data: (transactionList) => AsyncValue.data(
      transactionList.take(10).toList(),
    ),
    loading: () => const AsyncValue.loading(),
    error: AsyncValue.error,
  );
});

// Transactions by Date Range Provider
final transactionsByDateRangeProvider = Provider.family<List<TransactionModel>, DateRange>((ref, dateRange) {
  final transactions = ref.watch(transactionsProvider);
  return transactions.when(
    data: (transactionList) => transactionList.where((transaction) {
      return transaction.date.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
             transaction.date.isBefore(dateRange.end.add(const Duration(days: 1)));
    }).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Transactions by Type Provider
final transactionsByTypeProvider = Provider.family<List<TransactionModel>, TransactionType>((ref, type) {
  final transactions = ref.watch(transactionsProvider);
  return transactions.when(
    data: (transactionList) => transactionList.where((transaction) => transaction.type == type).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Transactions by Category Provider
final transactionsByCategoryProvider = Provider.family<List<TransactionModel>, String>((ref, categoryId) {
  final transactions = ref.watch(transactionsProvider);
  return transactions.when(
    data: (transactionList) => transactionList.where((transaction) => transaction.categoryId == categoryId).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Transactions by Account Provider
final transactionsByAccountProvider = Provider.family<List<TransactionModel>, String>((ref, accountId) {
  final transactions = ref.watch(transactionsProvider);
  return transactions.when(
    data: (transactionList) => transactionList.where((transaction) => 
      transaction.accountId == accountId || transaction.toAccountId == accountId).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Monthly Expenses Provider
final monthlyExpensesProvider = Provider<AsyncValue<double>>((ref) {
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month);
  final endOfMonth = DateTime(now.year, now.month + 1, 0);
  
  final transactions = ref.watch(transactionsByDateRangeProvider(
    DateRange(start: startOfMonth, end: endOfMonth),
  ));
  
  final totalExpenses = transactions
      .where((t) => t.type == TransactionType.expense)
      .fold<double>(0.0, (sum, t) => sum + t.amount);
  
  return AsyncValue.data(totalExpenses);
});

// Monthly Income Provider
final monthlyIncomeProvider = Provider<AsyncValue<double>>((ref) {
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month);
  final endOfMonth = DateTime(now.year, now.month + 1, 0);
  
  final transactions = ref.watch(transactionsByDateRangeProvider(
    DateRange(start: startOfMonth, end: endOfMonth),
  ));
  
  final totalIncome = transactions
      .where((t) => t.type == TransactionType.income)
      .fold<double>(0.0, (sum, t) => sum + t.amount);
  
  return AsyncValue.data(totalIncome);
});

// Weekly Expenses Provider (for chart)
final weeklyExpensesProvider = Provider<AsyncValue<List<double>>>((ref) {
  final transactions = ref.watch(transactionsProvider);

  return transactions.when(
    data: (transactionList) {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

      final weeklyData = <double>[];

      for (int i = 0; i < 7; i++) {
        final day = startOfWeek.add(Duration(days: i));
        final dayStart = DateTime(day.year, day.month, day.day);
        final dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59);

        final dayExpenses = transactionList
            .where((t) => t.type == TransactionType.expense)
            .where((t) => t.date.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
                         t.date.isBefore(dayEnd.add(const Duration(seconds: 1))))
            .fold<double>(0.0, (sum, t) => sum + t.amount);

        weeklyData.add(dayExpenses);
      }

      return AsyncValue.data(weeklyData);
    },
    loading: () => const AsyncValue.loading(),
    error: AsyncValue.error,
  );
});

// Transaction Statistics Provider
final transactionStatsProvider = Provider<AsyncValue<TransactionStats>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  
  return transactions.when(
    data: (transactionList) {
      final totalIncome = transactionList
          .where((t) => t.type == TransactionType.income)
          .fold<double>(0.0, (sum, t) => sum + t.amount);
      
      final totalExpenses = transactionList
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0.0, (sum, t) => sum + t.amount);
      
      final totalTransfers = transactionList
          .where((t) => t.type == TransactionType.transfer)
          .fold<double>(0.0, (sum, t) => sum + t.amount);
      
      return AsyncValue.data(TransactionStats(
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        totalTransfers: totalTransfers,
        netIncome: totalIncome - totalExpenses,
        transactionCount: transactionList.length,
      ));
    },
    loading: () => const AsyncValue.loading(),
    error: AsyncValue.error,
  );
});

// Transaction Creation Provider
final createTransactionProvider = Provider<Future<void> Function(TransactionModel)>((ref) {
  return (TransactionModel transaction) async {
    await ref.read(transactionsProvider.notifier).addTransaction(transaction);
  };
});

// Transaction Update Provider
final updateTransactionProvider = Provider<Future<void> Function(TransactionModel)>((ref) {
  return (TransactionModel transaction) async {
    await ref.read(transactionsProvider.notifier).updateTransaction(transaction);
  };
});

// Transaction Deletion Provider
final deleteTransactionProvider = Provider<Future<void> Function(String)>((ref) {
  return (String transactionId) async {
    await ref.read(transactionsProvider.notifier).deleteTransaction(transactionId);
  };
});

// Helper Classes
class DateRange {

  DateRange({required this.start, required this.end});
  final DateTime start;
  final DateTime end;
}

class TransactionStats {

  TransactionStats({
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalTransfers,
    required this.netIncome,
    required this.transactionCount,
  });
  final double totalIncome;
  final double totalExpenses;
  final double totalTransfers;
  final double netIncome;
  final int transactionCount;
}

// Helper function to create a new transaction
TransactionModel createNewTransaction({
  required double amount,
  required String description,
  required TransactionType type,
  required String categoryId,
  required String accountId,
  String? userId, // Optional for backward compatibility
  String? toAccountId,
  DateTime? date,
  String? notes,
}) {
  return TransactionModel(
    id: const Uuid().v4(),
    amount: amount,
    description: description,
    type: type,
    categoryId: categoryId,
    accountId: accountId,
    toAccountId: toAccountId,
    date: date ?? DateTime.now(),
    createdAt: DateTime.now(),
    notes: notes,
    userId: userId,
  );
}
