import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/hive_service.dart';
import '../data/models/transaction_model.dart';

// Transactions Provider
final transactionsProvider = StateNotifierProvider<TransactionsNotifier, AsyncValue<List<TransactionModel>>>((ref) {
  return TransactionsNotifier();
});

class TransactionsNotifier extends StateNotifier<AsyncValue<List<TransactionModel>>> {
  TransactionsNotifier() : super(const AsyncValue.loading()) {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactionBox = HiveService.transactionBox;
      final transactions = transactionBox.values.toList();
      transactions.sort((a, b) => b.date.compareTo(a.date));
      state = AsyncValue.data(transactions);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final transactionBox = HiveService.transactionBox;
      await transactionBox.put(transaction.id, transaction);
      await _loadTransactions();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      final transactionBox = HiveService.transactionBox;
      await transactionBox.put(transaction.id, transaction);
      await _loadTransactions();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      final transactionBox = HiveService.transactionBox;
      await transactionBox.delete(transactionId);
      await _loadTransactions();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void refresh() {
    _loadTransactions();
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
    error: (error, stack) => AsyncValue.error(error, stack),
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
  final startOfMonth = DateTime(now.year, now.month, 1);
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
  final startOfMonth = DateTime(now.year, now.month, 1);
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
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  
  final weeklyData = <double>[];
  
  for (int i = 0; i < 7; i++) {
    final day = startOfWeek.add(Duration(days: i));
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59);
    
    final dayTransactions = ref.watch(transactionsByDateRangeProvider(
      DateRange(start: dayStart, end: dayEnd),
    ));
    
    final dayExpenses = dayTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
    
    weeklyData.add(dayExpenses);
  }
  
  return AsyncValue.data(weeklyData);
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
    error: (error, stack) => AsyncValue.error(error, stack),
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
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});
}

class TransactionStats {
  final double totalIncome;
  final double totalExpenses;
  final double totalTransfers;
  final double netIncome;
  final int transactionCount;

  TransactionStats({
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalTransfers,
    required this.netIncome,
    required this.transactionCount,
  });
}

// Helper function to create a new transaction
TransactionModel createNewTransaction({
  required double amount,
  required String description,
  required TransactionType type,
  required String categoryId,
  required String accountId,
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
  );
}
