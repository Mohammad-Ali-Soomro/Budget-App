import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

// Data Models
class Transaction {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String account;
  final DateTime date;
  final TransactionType type;
  final String? description;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.account,
    required this.date,
    required this.type,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category,
    'account': account,
    'date': date.millisecondsSinceEpoch,
    'type': type.index,
    'description': description,
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    title: json['title'],
    amount: json['amount'],
    category: json['category'],
    account: json['account'],
    date: DateTime.fromMillisecondsSinceEpoch(json['date']),
    type: TransactionType.values[json['type']],
    description: json['description'],
  );
}

enum TransactionType { income, expense }

class Budget {
  final String id;
  final String category;
  final double limit;
  final double spent;
  final DateTime startDate;
  final DateTime endDate;

  Budget({
    required this.id,
    required this.category,
    required this.limit,
    required this.spent,
    required this.startDate,
    required this.endDate,
  });

  double get remaining => limit - spent;
  double get progress => spent / limit;

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'limit': limit,
    'spent': spent,
    'startDate': startDate.millisecondsSinceEpoch,
    'endDate': endDate.millisecondsSinceEpoch,
  };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
    id: json['id'],
    category: json['category'],
    limit: json['limit'],
    spent: json['spent'],
    startDate: DateTime.fromMillisecondsSinceEpoch(json['startDate']),
    endDate: DateTime.fromMillisecondsSinceEpoch(json['endDate']),
  );

  Budget copyWith({double? spent}) => Budget(
    id: id,
    category: category,
    limit: limit,
    spent: spent ?? this.spent,
    startDate: startDate,
    endDate: endDate,
  );
}

class Account {
  final String id;
  final String name;
  final String type;
  final double balance;
  final Color color;

  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'balance': balance,
    'color': color.value,
  };

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    balance: json['balance'],
    color: Color(json['color']),
  );

  Account copyWith({double? balance}) => Account(
    id: id,
    name: name,
    type: type,
    balance: balance ?? this.balance,
    color: color,
  );
}

// State Management
final transactionsProvider = StateNotifierProvider<TransactionsNotifier, List<Transaction>>((ref) {
  return TransactionsNotifier();
});

final budgetsProvider = StateNotifierProvider<BudgetsNotifier, List<Budget>>((ref) {
  return BudgetsNotifier();
});

final accountsProvider = StateNotifierProvider<AccountsNotifier, List<Account>>((ref) {
  return AccountsNotifier();
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

class AppSettings {
  final bool isDarkMode;
  final String language;
  final String currency;

  AppSettings({
    this.isDarkMode = false,
    this.language = 'English',
    this.currency = 'PKR',
  });

  AppSettings copyWith({bool? isDarkMode, String? language, String? currency}) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      currency: currency ?? this.currency,
    );
  }
}

class TransactionsNotifier extends StateNotifier<List<Transaction>> {
  TransactionsNotifier() : super([]) {
    _loadTransactions();
  }

  void _loadTransactions() async {
    final box = await Hive.openBox('transactions');
    final transactions = box.values
        .map((e) => Transaction.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    state = transactions;
  }

  void addTransaction(Transaction transaction) async {
    final box = await Hive.openBox('transactions');
    await box.put(transaction.id, transaction.toJson());
    state = [...state, transaction];
    state.sort((a, b) => b.date.compareTo(a.date));
  }

  void deleteTransaction(String id) async {
    final box = await Hive.openBox('transactions');
    await box.delete(id);
    state = state.where((t) => t.id != id).toList();
  }
}

class BudgetsNotifier extends StateNotifier<List<Budget>> {
  BudgetsNotifier() : super([]) {
    _loadBudgets();
  }

  void _loadBudgets() async {
    final box = await Hive.openBox('budgets');
    final budgets = box.values
        .map((e) => Budget.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    state = budgets;
  }

  void addBudget(Budget budget) async {
    final box = await Hive.openBox('budgets');
    await box.put(budget.id, budget.toJson());
    state = [...state, budget];
  }

  void updateBudgetSpent(String categoryId, double amount) async {
    final box = await Hive.openBox('budgets');
    final budgetIndex = state.indexWhere((b) => b.category == categoryId);
    if (budgetIndex != -1) {
      final updatedBudget = state[budgetIndex].copyWith(
        spent: state[budgetIndex].spent + amount,
      );
      await box.put(updatedBudget.id, updatedBudget.toJson());
      state = [
        ...state.sublist(0, budgetIndex),
        updatedBudget,
        ...state.sublist(budgetIndex + 1),
      ];
    }
  }

  void deleteBudget(String id) async {
    final box = await Hive.openBox('budgets');
    await box.delete(id);
    state = state.where((b) => b.id != id).toList();
  }
}

class AccountsNotifier extends StateNotifier<List<Account>> {
  AccountsNotifier() : super([]) {
    _loadAccounts();
  }

  void _loadAccounts() async {
    final box = await Hive.openBox('accounts');
    if (box.isEmpty) {
      // Initialize with default accounts
      await _initializeDefaultAccounts();
    }
    final accounts = box.values
        .map((e) => Account.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    state = accounts;
  }

  Future<void> _initializeDefaultAccounts() async {
    final defaultAccounts = [
      Account(
        id: 'cash',
        name: 'Cash Wallet',
        type: 'Cash',
        balance: 0,
        color: Colors.green,
      ),
      Account(
        id: 'bank',
        name: 'Bank Account',
        type: 'Bank',
        balance: 0,
        color: Colors.blue,
      ),
      Account(
        id: 'jazzcash',
        name: 'JazzCash',
        type: 'Mobile Wallet',
        balance: 0,
        color: Colors.orange,
      ),
    ];

    final box = await Hive.openBox('accounts');
    for (final account in defaultAccounts) {
      await box.put(account.id, account.toJson());
    }
  }

  void addAccount(Account account) async {
    final box = await Hive.openBox('accounts');
    await box.put(account.id, account.toJson());
    state = [...state, account];
  }

  void updateAccountBalance(String accountId, double amount) async {
    final box = await Hive.openBox('accounts');
    final accountIndex = state.indexWhere((a) => a.id == accountId);
    if (accountIndex != -1) {
      final updatedAccount = state[accountIndex].copyWith(
        balance: state[accountIndex].balance + amount,
      );
      await box.put(updatedAccount.id, updatedAccount.toJson());
      state = [
        ...state.sublist(0, accountIndex),
        updatedAccount,
        ...state.sublist(accountIndex + 1),
      ];
    }
  }

  void deleteAccount(String id) async {
    final box = await Hive.openBox('accounts');
    await box.delete(id);
    state = state.where((a) => a.id != id).toList();
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings()) {
    _loadSettings();
  }

  void _loadSettings() async {
    final box = await Hive.openBox('settings');
    final isDarkMode = box.get('isDarkMode', defaultValue: false);
    final language = box.get('language', defaultValue: 'English');
    final currency = box.get('currency', defaultValue: 'PKR');

    state = AppSettings(
      isDarkMode: isDarkMode,
      language: language,
      currency: currency,
    );
  }

  void toggleDarkMode() async {
    final box = await Hive.openBox('settings');
    await box.put('isDarkMode', !state.isDarkMode);
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  void setLanguage(String language) async {
    final box = await Hive.openBox('settings');
    await box.put('language', language);
    state = state.copyWith(language: language);
  }

  void setCurrency(String currency) async {
    final box = await Hive.openBox('settings');
    await box.put('currency', currency);
    state = state.copyWith(currency: currency);
  }
}

// Utility Functions
class CurrencyFormatter {
  static String format(double amount, {String currency = 'PKR'}) {
    final formatter = NumberFormat.currency(
      symbol: currency == 'PKR' ? 'PKR ' : '\$ ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}

// Categories Data
class Categories {
  static const Map<String, List<String>> pakistaniCategories = {
    'Food & Dining': ['Groceries', 'Restaurants', 'Fast Food', 'Bakery'],
    'Transportation': ['Fuel/Petrol', 'Public Transport', 'Rickshaw/Taxi', 'Car Maintenance'],
    'Utilities': ['Electricity (WAPDA/K-Electric)', 'Gas (SSGC/SNGPL)', 'Internet', 'Mobile/Phone Bill'],
    'Healthcare': ['Doctor Visits', 'Medicines', 'Hospital Bills', 'Medical Tests'],
    'Education': ['School Fees', 'University Fees', 'Books', 'Tuition'],
    'Shopping': ['Clothing', 'Electronics', 'Home Items', 'Personal Care'],
    'Entertainment': ['Movies', 'Sports', 'Games', 'Outings'],
    'Religious': ['Zakat', 'Sadaqah', 'Mosque Donations', 'Religious Books'],
    'Family': ['Children Expenses', 'Gifts', 'Family Events', 'Household'],
    'Business': ['Office Supplies', 'Business Travel', 'Professional Services'],
  };

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Food & Dining': return PhosphorIcons.forkKnife();
      case 'Transportation': return PhosphorIcons.car();
      case 'Utilities': return PhosphorIcons.lightbulb();
      case 'Healthcare': return PhosphorIcons.heartbeat();
      case 'Education': return PhosphorIcons.graduationCap();
      case 'Shopping': return PhosphorIcons.shoppingBag();
      case 'Entertainment': return PhosphorIcons.gameController();
      case 'Religious': return PhosphorIcons.mosque();
      case 'Family': return PhosphorIcons.users();
      case 'Business': return PhosphorIcons.briefcase();
      default: return PhosphorIcons.folder();
    }
  }

  static const Map<String, Color> categoryColors = {
    'Food & Dining': Colors.orange,
    'Transportation': Colors.blue,
    'Utilities': Colors.yellow,
    'Healthcare': Colors.red,
    'Education': Colors.purple,
    'Shopping': Colors.pink,
    'Entertainment': Colors.green,
    'Religious': Colors.teal,
    'Family': Colors.indigo,
    'Business': Colors.brown,
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const ProviderScope(child: BudgetApp()));
}

class BudgetApp extends ConsumerWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Budget App Pakistan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: settings.isDarkMode ? Brightness.dark : Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionsScreen(),
    const BudgetsScreen(),
    const AccountsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.house()),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.arrowsLeftRight()),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.wallet()),
            label: 'Budgets',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.bank()),
            label: 'Accounts',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.gear()),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Dashboard Screen with functional buttons
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final accounts = ref.watch(accountsProvider);

    // Calculate totals
    final totalBalance = accounts.fold(0.0, (sum, account) => sum + account.balance);
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Total Balance',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.format(totalBalance),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(PhosphorIcons.arrowUp(), color: Colors.green),
                            const Text('Income'),
                            Text(
                              CurrencyFormatter.format(totalIncome),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(PhosphorIcons.arrowDown(), color: Colors.red),
                            const Text('Expenses'),
                            Text(
                              CurrencyFormatter.format(totalExpenses),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick Actions - Now Functional
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: InkWell(
                      onTap: () => _showAddTransactionDialog(context, ref, TransactionType.income),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(PhosphorIcons.plus(), size: 32, color: Colors.green),
                            const SizedBox(height: 8),
                            const Text('Add Income'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: InkWell(
                      onTap: () => _showAddTransactionDialog(context, ref, TransactionType.expense),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(PhosphorIcons.minus(), size: 32, color: Colors.red),
                            const SizedBox(height: 8),
                            const Text('Add Expense'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Recent Transactions
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: transactions.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text('No transactions yet. Add your first transaction!'),
                      ),
                    )
                  : Column(
                      children: transactions.take(5).map((transaction) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: transaction.type == TransactionType.income
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            child: Icon(
                              Categories.getCategoryIcon(transaction.category),
                              color: transaction.type == TransactionType.income
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          title: Text(transaction.title),
                          subtitle: Text(transaction.category),
                          trailing: Text(
                            '${transaction.type == TransactionType.income ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
                            style: TextStyle(
                              color: transaction.type == TransactionType.income
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context, WidgetRef ref, TransactionType type) {
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(type: type),
    );
  }
}

// Add Transaction Dialog
class AddTransactionDialog extends ConsumerStatefulWidget {
  final TransactionType type;

  const AddTransactionDialog({super.key, required this.type});

  @override
  ConsumerState<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends ConsumerState<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Food & Dining';
  String _selectedAccount = '';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Set default category based on transaction type
    if (widget.type == TransactionType.income) {
      _selectedCategory = 'Business';
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);

    if (accounts.isNotEmpty && _selectedAccount.isEmpty) {
      _selectedAccount = accounts.first.id;
    }

    return AlertDialog(
      title: Text('Add ${widget.type == TransactionType.income ? 'Income' : 'Expense'}'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (PKR)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: Categories.pakistaniCategories.keys.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Icon(Categories.getCategoryIcon(category)),
                        const SizedBox(width: 8),
                        Text(category),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (accounts.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _selectedAccount,
                  decoration: const InputDecoration(
                    labelText: 'Account',
                    border: OutlineInputBorder(),
                  ),
                  items: accounts.map((account) {
                    return DropdownMenuItem(
                      value: account.id,
                      child: Text(account.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAccount = value!;
                    });
                  },
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                trailing: Icon(PhosphorIcons.calendar()),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveTransaction,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        amount: amount,
        category: _selectedCategory,
        account: _selectedAccount,
        date: _selectedDate,
        type: widget.type,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      );

      // Add transaction
      ref.read(transactionsProvider.notifier).addTransaction(transaction);

      // Update account balance
      final balanceChange = widget.type == TransactionType.income ? amount : -amount;
      ref.read(accountsProvider.notifier).updateAccountBalance(_selectedAccount, balanceChange);

      // Update budget if expense
      if (widget.type == TransactionType.expense) {
        ref.read(budgetsProvider.notifier).updateBudgetSpent(_selectedCategory, amount);
      }

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.type == TransactionType.income ? 'Income' : 'Expense'} added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

// Transactions Screen
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: transactions.isEmpty
          ? const Center(
              child: Text('No transactions yet. Add your first transaction!'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: transaction.type == TransactionType.income
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      child: Icon(
                        Categories.getCategoryIcon(transaction.category),
                        color: transaction.type == TransactionType.income
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    title: Text(transaction.title),
                    subtitle: Text('${transaction.category} • ${DateFormat('MMM dd, yyyy').format(transaction.date)}'),
                    trailing: Text(
                      '${transaction.type == TransactionType.income ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
                      style: TextStyle(
                        color: transaction.type == TransactionType.income
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context, ref),
        child: Icon(PhosphorIcons.plus()),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const AddTransactionDialog(type: TransactionType.expense),
    );
  }
}

// Budgets Screen
class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: budgets.isEmpty
          ? const Center(
              child: Text('No budgets yet. Create your first budget!'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                final budget = budgets[index];
                final progress = budget.progress.clamp(0.0, 1.0);
                final progressColor = progress > 0.8 ? Colors.red : progress > 0.6 ? Colors.orange : Colors.green;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: progressColor.withValues(alpha: 0.1),
                              child: Icon(Categories.getCategoryIcon(budget.category), color: progressColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    budget.category,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('Budget: ${CurrencyFormatter.format(budget.limit)}'),
                                ],
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(budget.spent),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: progressColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(progress * 100).toInt()}% used • Remaining: ${CurrencyFormatter.format(budget.remaining)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context, ref),
        child: Icon(PhosphorIcons.plus()),
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const AddBudgetDialog(),
    );
  }
}

// Add Budget Dialog
class AddBudgetDialog extends ConsumerStatefulWidget {
  const AddBudgetDialog({super.key});

  @override
  ConsumerState<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends ConsumerState<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();

  String _selectedCategory = 'Food & Dining';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Budget'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: Categories.pakistaniCategories.keys.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(Categories.getCategoryIcon(category)),
                      const SizedBox(width: 8),
                      Text(category),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _limitController,
              decoration: const InputDecoration(
                labelText: 'Budget Limit (PKR)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a budget limit';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveBudget,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _saveBudget() {
    if (_formKey.currentState!.validate()) {
      final limit = double.parse(_limitController.text);
      final budget = Budget(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: _selectedCategory,
        limit: limit,
        spent: 0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      );

      ref.read(budgetsProvider.notifier).addBudget(budget);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Budget created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }
}

// Accounts Screen
class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);
    final totalBalance = accounts.fold(0.0, (sum, account) => sum + account.balance);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Total Balance Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.format(totalBalance),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Accounts List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: account.color.withValues(alpha: 0.1),
                      child: Icon(
                        account.type == 'Cash' ? PhosphorIcons.wallet() :
                        account.type == 'Bank' ? PhosphorIcons.bank() :
                        PhosphorIcons.deviceMobile(),
                        color: account.color,
                      ),
                    ),
                    title: Text(
                      account.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(account.type),
                    trailing: Text(
                      CurrencyFormatter.format(account.balance),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Settings Screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green.withValues(alpha: 0.1),
                    child: Icon(
                      PhosphorIcons.user(),
                      size: 30,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget User',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Managing finances in Pakistan',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Settings Options
          const Text(
            'Preferences',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle dark theme'),
                  value: settings.isDarkMode,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).toggleDarkMode();
                  },
                  secondary: Icon(PhosphorIcons.moon()),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(PhosphorIcons.translate()),
                  title: const Text('Language'),
                  subtitle: Text(settings.language),
                  trailing: Icon(PhosphorIcons.caretRight()),
                  onTap: () => _showLanguageDialog(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(PhosphorIcons.currencyDollar()),
                  title: const Text('Currency'),
                  subtitle: Text(settings.currency),
                  trailing: Icon(PhosphorIcons.caretRight()),
                  onTap: () => _showCurrencyDialog(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                ref.read(settingsProvider.notifier).setLanguage('English');
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('اردو (Urdu)'),
              onTap: () {
                ref.read(settingsProvider.notifier).setLanguage('Urdu');
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Pakistani Rupee (PKR)'),
              onTap: () {
                ref.read(settingsProvider.notifier).setCurrency('PKR');
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('US Dollar (USD)'),
              onTap: () {
                ref.read(settingsProvider.notifier).setCurrency('USD');
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
