import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/hive_service.dart';
import '../data/models/account_model.dart';

// Accounts Provider
final accountsProvider = StateNotifierProvider<AccountsNotifier, AsyncValue<List<AccountModel>>>((ref) {
  return AccountsNotifier();
});

class AccountsNotifier extends StateNotifier<AsyncValue<List<AccountModel>>> {
  AccountsNotifier() : super(const AsyncValue.loading()) {
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      final accountBox = HiveService.accountBox;
      final accounts = accountBox.values.where((account) => account.isActive).toList();
      accounts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = AsyncValue.data(accounts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addAccount(AccountModel account) async {
    try {
      final accountBox = HiveService.accountBox;
      await accountBox.put(account.id, account);
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

// Total Balance Provider
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
  );
}
