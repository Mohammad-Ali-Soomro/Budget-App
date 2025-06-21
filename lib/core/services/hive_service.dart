import 'package:hive_flutter/hive_flutter.dart';
import '../config/app_config.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../../features/categories/data/models/category_model.dart';
import '../../features/accounts/data/models/account_model.dart';
import '../../features/budgets/data/models/budget_model.dart';
import '../../features/goals/data/models/goal_model.dart';
import '../../features/reminders/data/models/reminder_model.dart';
import '../../features/auth/data/models/user_model.dart';

class HiveService {
  static late Box<UserModel> _userBox;
  static late Box<TransactionModel> _transactionBox;
  static late Box<CategoryModel> _categoryBox;
  static late Box<AccountModel> _accountBox;
  static late Box<BudgetModel> _budgetBox;
  static late Box<GoalModel> _goalBox;
  static late Box<ReminderModel> _reminderBox;
  static late Box _settingsBox;

  static Future<void> init() async {
    // Register adapters
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(AccountModelAdapter());
    Hive.registerAdapter(BudgetModelAdapter());
    Hive.registerAdapter(GoalModelAdapter());
    Hive.registerAdapter(ReminderModelAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(AccountTypeAdapter());
    Hive.registerAdapter(BudgetPeriodAdapter());
    Hive.registerAdapter(GoalStatusAdapter());
    Hive.registerAdapter(ReminderFrequencyAdapter());

    // Open boxes
    _userBox = await Hive.openBox<UserModel>(AppConfig.userBox);
    _transactionBox = await Hive.openBox<TransactionModel>(AppConfig.transactionBox);
    _categoryBox = await Hive.openBox<CategoryModel>(AppConfig.categoryBox);
    _accountBox = await Hive.openBox<AccountModel>(AppConfig.accountBox);
    _budgetBox = await Hive.openBox<BudgetModel>(AppConfig.budgetBox);
    _goalBox = await Hive.openBox<GoalModel>(AppConfig.goalBox);
    _reminderBox = await Hive.openBox<ReminderModel>(AppConfig.reminderBox);
    _settingsBox = await Hive.openBox(AppConfig.settingsBox);

    // Initialize default data if first time
    await _initializeDefaultData();
  }

  static Future<void> _initializeDefaultData() async {
    // Initialize default categories if empty
    if (_categoryBox.isEmpty) {
      await _initializeDefaultCategories();
    }

    // Initialize default accounts if empty
    if (_accountBox.isEmpty) {
      await _initializeDefaultAccounts();
    }
  }

  static Future<void> _initializeDefaultCategories() async {
    int index = 0;
    for (final entry in AppConfig.defaultCategories.entries) {
      final parentCategory = CategoryModel(
        id: 'cat_${index++}',
        name: entry.key,
        icon: _getCategoryIcon(entry.key),
        color: _getCategoryColor(index),
        isDefault: true,
        createdAt: DateTime.now(),
      );
      await _categoryBox.put(parentCategory.id, parentCategory);

      // Add subcategories
      for (final subCatName in entry.value) {
        final subCategory = CategoryModel(
          id: 'cat_${index++}',
          name: subCatName,
          icon: _getCategoryIcon(subCatName),
          color: parentCategory.color,
          parentId: parentCategory.id,
          isDefault: true,
          createdAt: DateTime.now(),
        );
        await _categoryBox.put(subCategory.id, subCategory);
      }
    }
  }

  static Future<void> _initializeDefaultAccounts() async {
    // Cash account
    final cashAccount = AccountModel(
      id: 'acc_cash',
      name: 'Cash',
      type: AccountType.cash,
      balance: 0.0,
      currency: AppConfig.defaultCurrency,
      isDefault: true,
      createdAt: DateTime.now(),
    );
    await _accountBox.put(cashAccount.id, cashAccount);

    // Default bank account
    final bankAccount = AccountModel(
      id: 'acc_bank',
      name: 'Bank Account',
      type: AccountType.bank,
      balance: 0.0,
      currency: AppConfig.defaultCurrency,
      bankName: 'Select Bank',
      isDefault: true,
      createdAt: DateTime.now(),
    );
    await _accountBox.put(bankAccount.id, bankAccount);
  }

  static String _getCategoryIcon(String categoryName) {
    final iconMap = {
      'Food & Dining': '🍽️',
      'Transportation': '🚗',
      'Utilities': '💡',
      'Healthcare': '🏥',
      'Education': '📚',
      'Shopping': '🛍️',
      'Entertainment': '🎬',
      'Religious': '🕌',
      'Family': '👨‍👩‍👧‍👦',
      'Business': '💼',
      'Groceries': '🛒',
      'Restaurants': '🍽️',
      'Fast Food': '🍔',
      'Fuel/Petrol': '⛽',
      'Public Transport': '🚌',
      'Electricity (WAPDA/K-Electric)': '💡',
      'Gas (SSGC/SNGPL)': '🔥',
      'Internet': '🌐',
      'Mobile/Phone Bill': '📱',
      'Doctor Visits': '👨‍⚕️',
      'Medicines': '💊',
      'School Fees': '🏫',
      'University Fees': '🎓',
      'Clothing': '👕',
      'Electronics': '📱',
      'Movies': '🎬',
      'Sports': '⚽',
      'Zakat': '💰',
      'Sadaqah': '🤲',
    };
    return iconMap[categoryName] ?? '📝';
  }

  static int _getCategoryColor(int index) {
    final colors = [
      0xFF4CAF50, // Green
      0xFF2196F3, // Blue
      0xFFFF9800, // Orange
      0xFFE91E63, // Pink
      0xFF9C27B0, // Purple
      0xFF00BCD4, // Cyan
      0xFFFF5722, // Deep Orange
      0xFF795548, // Brown
      0xFF607D8B, // Blue Grey
      0xFFFFC107, // Amber
    ];
    return colors[index % colors.length];
  }

  // Getters for boxes
  static Box<UserModel> get userBox => _userBox;
  static Box<TransactionModel> get transactionBox => _transactionBox;
  static Box<CategoryModel> get categoryBox => _categoryBox;
  static Box<AccountModel> get accountBox => _accountBox;
  static Box<BudgetModel> get budgetBox => _budgetBox;
  static Box<GoalModel> get goalBox => _goalBox;
  static Box<ReminderModel> get reminderBox => _reminderBox;
  static Box get settingsBox => _settingsBox;

  // Close all boxes
  static Future<void> closeBoxes() async {
    await _userBox.close();
    await _transactionBox.close();
    await _categoryBox.close();
    await _accountBox.close();
    await _budgetBox.close();
    await _goalBox.close();
    await _reminderBox.close();
    await _settingsBox.close();
  }

  // Clear all data (for testing or reset)
  static Future<void> clearAllData() async {
    await _userBox.clear();
    await _transactionBox.clear();
    await _categoryBox.clear();
    await _accountBox.clear();
    await _budgetBox.clear();
    await _goalBox.clear();
    await _reminderBox.clear();
    await _settingsBox.clear();
    
    // Reinitialize default data
    await _initializeDefaultData();
  }
}
