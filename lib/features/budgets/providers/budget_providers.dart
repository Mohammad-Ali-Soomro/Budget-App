import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/hive_service.dart';
import '../data/models/budget_model.dart';
import '../../transactions/providers/transaction_providers.dart';

// Budgets Provider
final budgetsProvider = StateNotifierProvider<BudgetsNotifier, AsyncValue<List<BudgetModel>>>((ref) {
  return BudgetsNotifier();
});

class BudgetsNotifier extends StateNotifier<AsyncValue<List<BudgetModel>>> {
  BudgetsNotifier() : super(const AsyncValue.loading()) {
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    try {
      final budgetBox = HiveService.budgetBox;
      final budgets = budgetBox.values.toList();
      budgets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = AsyncValue.data(budgets);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addBudget(BudgetModel budget) async {
    try {
      final budgetBox = HiveService.budgetBox;
      await budgetBox.put(budget.id, budget);
      await _loadBudgets();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateBudget(BudgetModel budget) async {
    try {
      final budgetBox = HiveService.budgetBox;
      await budgetBox.put(budget.id, budget);
      await _loadBudgets();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteBudget(String budgetId) async {
    try {
      final budgetBox = HiveService.budgetBox;
      await budgetBox.delete(budgetId);
      await _loadBudgets();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateBudgetSpent(String budgetId, double newSpent) async {
    try {
      final budgetBox = HiveService.budgetBox;
      final budget = budgetBox.get(budgetId);
      if (budget != null) {
        final updatedBudget = budget.copyWith(spent: newSpent);
        await budgetBox.put(budgetId, updatedBudget);
        await _loadBudgets();
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void refresh() {
    _loadBudgets();
  }
}

// Active Budgets Provider
final activeBudgetsProvider = Provider<AsyncValue<List<BudgetModel>>>((ref) {
  final budgets = ref.watch(budgetsProvider);
  return budgets.when(
    data: (budgetList) => AsyncValue.data(
      budgetList.where((budget) => budget.isActive && !budget.isExpired).toList(),
    ),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Current Month Budgets Provider
final currentMonthBudgetsProvider = Provider<AsyncValue<List<BudgetModel>>>((ref) {
  final budgets = ref.watch(budgetsProvider);
  final now = DateTime.now();
  
  return budgets.when(
    data: (budgetList) => AsyncValue.data(
      budgetList.where((budget) {
        return budget.isActive &&
               budget.startDate.month == now.month &&
               budget.startDate.year == now.year;
      }).toList(),
    ),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Budget by ID Provider
final budgetByIdProvider = Provider.family<BudgetModel?, String>((ref, budgetId) {
  final budgets = ref.watch(budgetsProvider);
  return budgets.when(
    data: (budgetList) => budgetList.firstWhere(
      (budget) => budget.id == budgetId,
      orElse: () => budgetList.first,
    ),
    loading: () => null,
    error: (_, __) => null,
  );
});

// Budget by Category Provider
final budgetByCategoryProvider = Provider.family<BudgetModel?, String>((ref, categoryId) {
  final budgets = ref.watch(activeBudgetsProvider);
  return budgets.when(
    data: (budgetList) => budgetList.firstWhere(
      (budget) => budget.categoryId == categoryId,
      orElse: () => budgetList.first,
    ),
    loading: () => null,
    error: (_, __) => null,
  );
});

// Exceeded Budgets Provider
final exceededBudgetsProvider = Provider<List<BudgetModel>>((ref) {
  final budgets = ref.watch(activeBudgetsProvider);
  return budgets.when(
    data: (budgetList) => budgetList.where((budget) => budget.isExceeded).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Near Limit Budgets Provider
final nearLimitBudgetsProvider = Provider<List<BudgetModel>>((ref) {
  final budgets = ref.watch(activeBudgetsProvider);
  return budgets.when(
    data: (budgetList) => budgetList.where((budget) => budget.isNearLimit && !budget.isExceeded).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Budget Statistics Provider
final budgetStatsProvider = Provider<AsyncValue<BudgetStats>>((ref) {
  final budgets = ref.watch(activeBudgetsProvider);
  
  return budgets.when(
    data: (budgetList) {
      final totalBudgeted = budgetList.fold<double>(0.0, (sum, budget) => sum + budget.amount);
      final totalSpent = budgetList.fold<double>(0.0, (sum, budget) => sum + budget.spent);
      final exceededCount = budgetList.where((budget) => budget.isExceeded).length;
      final nearLimitCount = budgetList.where((budget) => budget.isNearLimit && !budget.isExceeded).length;
      
      return AsyncValue.data(BudgetStats(
        totalBudgeted: totalBudgeted,
        totalSpent: totalSpent,
        remaining: totalBudgeted - totalSpent,
        exceededCount: exceededCount,
        nearLimitCount: nearLimitCount,
        totalBudgets: budgetList.length,
      ));
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Budget Progress Provider
final budgetProgressProvider = Provider.family<double, String>((ref, budgetId) {
  final budget = ref.watch(budgetByIdProvider(budgetId));
  if (budget == null) return 0.0;
  
  // Calculate spent amount from transactions
  final transactions = ref.watch(transactionsByCategoryProvider(budget.categoryId));
  final spent = transactions
      .where((t) => t.type == TransactionType.expense)
      .where((t) => t.date.isAfter(budget.startDate) && t.date.isBefore(budget.endDate))
      .fold<double>(0.0, (sum, t) => sum + t.amount);
  
  // Update budget spent amount
  if (spent != budget.spent) {
    Future.microtask(() {
      ref.read(budgetsProvider.notifier).updateBudgetSpent(budgetId, spent);
    });
  }
  
  return budget.amount > 0 ? (spent / budget.amount).clamp(0.0, 1.0) : 0.0;
});

// Budget Creation Provider
final createBudgetProvider = Provider<Future<void> Function(BudgetModel)>((ref) {
  return (BudgetModel budget) async {
    await ref.read(budgetsProvider.notifier).addBudget(budget);
  };
});

// Budget Update Provider
final updateBudgetProvider = Provider<Future<void> Function(BudgetModel)>((ref) {
  return (BudgetModel budget) async {
    await ref.read(budgetsProvider.notifier).updateBudget(budget);
  };
});

// Budget Deletion Provider
final deleteBudgetProvider = Provider<Future<void> Function(String)>((ref) {
  return (String budgetId) async {
    await ref.read(budgetsProvider.notifier).deleteBudget(budgetId);
  };
});

// Helper Classes
class BudgetStats {
  final double totalBudgeted;
  final double totalSpent;
  final double remaining;
  final int exceededCount;
  final int nearLimitCount;
  final int totalBudgets;

  BudgetStats({
    required this.totalBudgeted,
    required this.totalSpent,
    required this.remaining,
    required this.exceededCount,
    required this.nearLimitCount,
    required this.totalBudgets,
  });
}

// Helper function to create a new budget
BudgetModel createNewBudget({
  required String name,
  required String categoryId,
  required double amount,
  required BudgetPeriod period,
  required DateTime startDate,
  required DateTime endDate,
  double alertThreshold = 0.8,
  String? description,
}) {
  return BudgetModel(
    id: const Uuid().v4(),
    name: name,
    categoryId: categoryId,
    amount: amount,
    period: period,
    startDate: startDate,
    endDate: endDate,
    alertThreshold: alertThreshold,
    description: description,
    createdAt: DateTime.now(),
  );
}

// Helper function to calculate budget period dates
DateRange calculateBudgetPeriod(BudgetPeriod period, DateTime startDate) {
  DateTime endDate;
  
  switch (period) {
    case BudgetPeriod.weekly:
      endDate = startDate.add(const Duration(days: 7));
      break;
    case BudgetPeriod.monthly:
      endDate = DateTime(startDate.year, startDate.month + 1, startDate.day);
      break;
    case BudgetPeriod.quarterly:
      endDate = DateTime(startDate.year, startDate.month + 3, startDate.day);
      break;
    case BudgetPeriod.yearly:
      endDate = DateTime(startDate.year + 1, startDate.month, startDate.day);
      break;
  }
  
  return DateRange(start: startDate, end: endDate);
}
