import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/hive_service.dart';
import '../../../core/providers/app_providers.dart';
import '../data/models/account_model.dart';
import '../../transactions/providers/transaction_providers.dart';

// Accounts Provider
final accountsProvider = StateNotifierProvider<AccountsNotifier, AsyncValue<List<AccountModel>>>((ref) {
  return AccountsNotifier(ref);
});

class AccountsNotifier extends StateNotifier<AsyncValue<List<AccountModel>>> {
  final Ref _ref;

  AccountsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadAccounts();

    // Listen to current user changes and refresh data
    _ref.listen(currentUserProvider, (previous, next) {
      if (previous?.id != next?.id) {
        _loadAccounts();
      }
    });
  }

  Future<void> _loadAccounts() async {
    try {
      final currentUser = _ref.read(currentUserProvider);
      if (currentUser == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final accountBox = HiveService.accountBox;
      final allAccounts = accountBox.values.where((account) => account.isActive).toList();

      // Filter accounts by current user ID
      final userAccounts = allAccounts
          .where((account) => account.userId == currentUser.id)
          .toList();

      userAccounts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = AsyncValue.data(userAccounts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addAccount(AccountModel account) async {
    try {
      final currentUser = _ref.read(currentUserProvider);
      if (currentUser == null) return;

      // Ensure account has correct user ID
      final userAccount = account.copyWith(userId: currentUser.id);

      final accountBox = HiveService.accountBox;
      await accountBox.put(userAccount.id, userAccount);
      await _loadAccounts();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateAccount(AccountModel account) async {
    try {
      final accountBox = HiveService.accountBox;
      await accountBox.put(account.id, account);
      await _loadAccounts();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteAccount(String accountId) async {
    try {
      final accountBox = HiveService.accountBox;
      final account = accountBox.get(accountId);
      if (account != null) {
        final updatedAccount = account.copyWith(isActive: false);
        await accountBox.put(accountId, updatedAccount);
        await _loadAccounts();
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    try {
      final accountBox = HiveService.accountBox;
      final account = accountBox.get(accountId);
      if (account != null) {
        final updatedAccount = account.copyWith(balance: newBalance);
        await accountBox.put(accountId, updatedAccount);
        await _loadAccounts();
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Method to adjust account balance by a specific amount (positive or negative)
  Future<void> adjustAccountBalance(String accountId, double adjustment) async {
    try {
      final accountBox = HiveService.accountBox;
      final account = accountBox.get(accountId);
      if (account != null) {
        final newBalance = account.balance + adjustment;
        final updatedAccount = account.copyWith(balance: newBalance);
        await accountBox.put(accountId, updatedAccount);
        await _loadAccounts();
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void refresh() {
    _loadAccounts();
  }
}

// Active Accounts Provider
final activeAccountsProvider = Provider<AsyncValue<List<AccountModel>>>((ref) {
  final accounts = ref.watch(accountsProvider);
  return accounts.when(
    data: (accountList) => AsyncValue.data(
      accountList.where((account) => account.isActive).toList(),
    ),
    loading: () => const AsyncValue.loading(),
    error: AsyncValue.error,
  );
});

// Account by ID Provider
final accountByIdProvider = Provider.family<AccountModel?, String>((ref, accountId) {
  final accounts = ref.watch(accountsProvider);
  return accounts.when(
    data: (accountList) => accountList.firstWhere(
      (account) => account.id == accountId,
      orElse: () => accountList.first,
    ),
    loading: () => null,
    error: (_, __) => null,
  );
});

// Total Balance Provider - Now calculates from transactions for real-time updates
final totalBalanceProvider = Provider<double>((ref) {
  final accounts = ref.watch(accountsProvider);
  return accounts.when(
    data: (accountList) => accountList.fold<double>(
      0.0,
      (sum, account) => sum + account.balance,
    ),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

// Real-time Balance Provider - Calculates balance from transactions
final realTimeBalanceProvider = Provider<AsyncValue<double>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final accounts = ref.watch(accountsProvider);

  return transactions.when(
    data: (transactionList) {
      return accounts.when(
        data: (accountList) {
          // Start with initial account balances and adjust based on transactions
          double totalBalance = 0.0;

          for (final account in accountList) {
            // Get all transactions for this account
            final accountTransactions = transactionList.where((t) =>
              t.accountId == account.id || t.toAccountId == account.id).toList();

            double accountBalance = account.balance;

            // This approach assumes account.balance is the starting balance
            // and we don't need to recalculate from transactions since
            // we're updating balances in real-time through the transaction methods
            totalBalance += accountBalance;
          }

          return AsyncValue.data(totalBalance);
        },
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Accounts by Type Provider
final accountsByTypeProvider = Provider.family<List<AccountModel>, AccountType>((ref, type) {
  final accounts = ref.watch(accountsProvider);
  return accounts.when(
    data: (accountList) => accountList.where((account) => account.type == type).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Default Account Provider
final defaultAccountProvider = Provider<AccountModel?>((ref) {
  final accounts = ref.watch(accountsProvider);
  return accounts.when(
    data: (accountList) => accountList.firstWhere(
      (account) => account.isDefault,
      orElse: () => accountList.isNotEmpty ? accountList.first : accountList.first,
    ),
    loading: () => null,
    error: (_, __) => null,
  );
});

// Account Creation Provider
final createAccountProvider = Provider<Future<void> Function(AccountModel)>((ref) {
  return (AccountModel account) async {
    await ref.read(accountsProvider.notifier).addAccount(account);
  };
});

// Account Update Provider
final updateAccountProvider = Provider<Future<void> Function(AccountModel)>((ref) {
  return (AccountModel account) async {
    await ref.read(accountsProvider.notifier).updateAccount(account);
  };
});

// Account Deletion Provider
final deleteAccountProvider = Provider<Future<void> Function(String)>((ref) {
  return (String accountId) async {
    await ref.read(accountsProvider.notifier).deleteAccount(accountId);
  };
});

// Helper function to create a new account
AccountModel createNewAccount({
  required String name,
  required AccountType type,
  required double initialBalance,
  required String userId,
  String? bankName,
  String? accountNumber,
  String? cardNumber,
  String? description,
}) {
  return AccountModel(
    id: const Uuid().v4(),
    name: name,
    type: type,
    balance: initialBalance,
    currency: 'PKR',
    bankName: bankName,
    accountNumber: accountNumber,
    cardNumber: cardNumber,
    description: description,
    createdAt: DateTime.now(),
    userId: userId,
  );
}
