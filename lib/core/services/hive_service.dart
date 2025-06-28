import 'package:hive_flutter/hive_flutter.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../../features/categories/data/models/category_model.dart';
import '../../features/accounts/data/models/account_model.dart';
import '../../features/budgets/data/models/budget_model.dart';
import '../../features/goals/data/models/goal_model.dart';
import '../../features/reminders/data/models/reminder_model.dart';

class HiveService {
  static late Box _settingsBox;
  static late Box<UserModel> _userBox;
  static late Box<TransactionModel> _transactionBox;
  static late Box<CategoryModel> _categoryBox;
  static late Box<AccountModel> _accountBox;
  static late Box<BudgetModel> _budgetBox;
  static late Box<GoalModel> _goalBox;
  static late Box<ReminderModel> _reminderBox;

  static Future<void> init() async {
    try {
      await Hive.initFlutter();

      // Register adapters with error handling
      _registerAdapters();

      // Open boxes with error handling
      await _openBoxes();

      // Initialize default data if needed
      await _initializeDefaultData();
    } catch (e) {
      print('Error initializing Hive: $e');
      rethrow;
    }
  }

  static void _registerAdapters() {
    try {
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(UserModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(TransactionTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(TransactionModelAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(CategoryModelAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(AccountTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(AccountModelAdapter());
      }
      if (!Hive.isAdapterRegistered(6)) {
        Hive.registerAdapter(BudgetPeriodAdapter());
      }
      if (!Hive.isAdapterRegistered(7)) {
        Hive.registerAdapter(BudgetModelAdapter());
      }
      if (!Hive.isAdapterRegistered(8)) {
        Hive.registerAdapter(GoalStatusAdapter());
      }
      if (!Hive.isAdapterRegistered(9)) {
        Hive.registerAdapter(GoalModelAdapter());
      }
      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(ReminderFrequencyAdapter());
      }
      if (!Hive.isAdapterRegistered(11)) {
        Hive.registerAdapter(ReminderModelAdapter());
      }
    } catch (e) {
      print('Error registering Hive adapters: $e');
      rethrow;
    }
  }

  static Future<void> _openBoxes() async {
    try {
      _settingsBox = await Hive.openBox('settings');
      _userBox = await Hive.openBox<UserModel>('users');
      _transactionBox = await Hive.openBox<TransactionModel>('transactions');
      _categoryBox = await Hive.openBox<CategoryModel>('categories');
      _accountBox = await Hive.openBox<AccountModel>('accounts');
      _budgetBox = await Hive.openBox<BudgetModel>('budgets');
      _goalBox = await Hive.openBox<GoalModel>('goals');
      _reminderBox = await Hive.openBox<ReminderModel>('reminders');
    } catch (e) {
      print('Error opening Hive boxes: $e');
      rethrow;
    }
  }

  // Getters for boxes
  static Box get settingsBox => _settingsBox;
  static Box<UserModel> get userBox => _userBox;
  static Box<TransactionModel> get transactionBox => _transactionBox;
  static Box<CategoryModel> get categoryBox => _categoryBox;
  static Box<AccountModel> get accountBox => _accountBox;
  static Box<BudgetModel> get budgetBox => _budgetBox;
  static Box<GoalModel> get goalBox => _goalBox;
  static Box<ReminderModel> get reminderBox => _reminderBox;

  // Initialize default data
  static Future<void> _initializeDefaultData() async {
    // Check if we need to migrate data due to schema changes
    await _migrateDataIfNeeded();

    // Initialize default categories if empty
    if (_categoryBox.isEmpty) {
      await _initializeDefaultCategories();
    }

    // Don't initialize default accounts automatically
    // They should be created per user when they first sign up
  }

  // Migrate data if schema has changed (added userId fields)
  static Future<void> _migrateDataIfNeeded() async {
    try {
      // Check if we have a migration flag
      final settingsBox = HiveService.settingsBox;
      final hasUserIdMigration = settingsBox.get('userId_migration_completed', defaultValue: false);

      if (!hasUserIdMigration) {
        print('Performing userId migration - clearing existing data...');

        // Clear existing data that doesn't have userId field
        await _transactionBox.clear();
        await _accountBox.clear();
        await _budgetBox.clear();

        // Mark migration as completed
        await settingsBox.put('userId_migration_completed', true);

        print('Migration completed successfully');
      }
    } catch (e) {
      print('Error during migration: $e');
      // Continue anyway - app should still work
    }
  }

  static Future<void> _initializeDefaultCategories() async {
    final defaultCategories = [
      CategoryModel(
        id: 'food_dining',
        name: 'Food & Dining',
        icon: '🍽️',
        color: 0xFFFF9800,
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: 'transportation',
        name: 'Transportation',
        icon: '🚗',
        color: 0xFF2196F3,
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: 'utilities',
        name: 'Utilities',
        icon: '💡',
        color: 0xFFFFEB3B,
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: 'healthcare',
        name: 'Healthcare',
        icon: '🏥',
        color: 0xFFF44336,
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: 'education',
        name: 'Education',
        icon: '🎓',
        color: 0xFF9C27B0,
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: 'shopping',
        name: 'Shopping',
        icon: '🛍️',
        color: 0xFFE91E63,
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: 'entertainment',
        name: 'Entertainment',
        icon: '🎮',
        color: 0xFF4CAF50,
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: 'religious',
        name: 'Religious',
        icon: '🕌',
        color: 0xFF009688,
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: 'family',
        name: 'Family',
        icon: '👨‍👩‍👧‍👦',
        color: 0xFF3F51B5,
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: 'business',
        name: 'Business',
        icon: '💼',
        color: 0xFF795548,
        isDefault: true,
        createdAt: DateTime.now(),
      ),
    ];

    for (final category in defaultCategories) {
      await _categoryBox.put(category.id, category);
    }
  }



  // Close all boxes
  static Future<void> closeBoxes() async {
    await _settingsBox.close();
    await _userBox.close();
    await _transactionBox.close();
    await _categoryBox.close();
    await _accountBox.close();
    await _budgetBox.close();
    await _goalBox.close();
    await _reminderBox.close();
  }

  // Clear all data (for testing or reset)
  static Future<void> clearAllData() async {
    await _settingsBox.clear();
    await _userBox.clear();
    await _transactionBox.clear();
    await _categoryBox.clear();
    await _accountBox.clear();
    await _budgetBox.clear();
    await _goalBox.clear();
    await _reminderBox.clear();
  }
}
