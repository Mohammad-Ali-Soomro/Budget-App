class AppConfig {
  static const String appName = 'Budget Manager PK';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.budgetapp.pk';
  
  // Database
  static const String databaseName = 'budget_app_pk.db';
  static const int databaseVersion = 1;
  
  // Hive Boxes
  static const String userBox = 'user_box';
  static const String transactionBox = 'transaction_box';
  static const String categoryBox = 'category_box';
  static const String accountBox = 'account_box';
  static const String budgetBox = 'budget_box';
  static const String goalBox = 'goal_box';
  static const String reminderBox = 'reminder_box';
  static const String settingsBox = 'settings_box';
  
  // Currency
  static const String defaultCurrency = 'PKR';
  static const String currencySymbol = 'Rs.';
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Pakistani Banks and Payment Methods
  static const List<String> pakistaniBanks = [
    'HBL - Habib Bank Limited',
    'UBL - United Bank Limited',
    'NBP - National Bank of Pakistan',
    'MCB - Muslim Commercial Bank',
    'ABL - Allied Bank Limited',
    'Standard Chartered Bank',
    'Faysal Bank',
    'Bank Alfalah',
    'Askari Bank',
    'Soneri Bank',
    'Bank Al Habib',
    'JS Bank',
    'Silk Bank',
    'Summit Bank',
    'First Women Bank',
  ];
  
  static const List<String> mobileWallets = [
    'JazzCash',
    'Easypaisa',
    'UBL Omni',
    'HBL Konnect',
    'Sadapay',
    'Nayapay',
    'Oraan',
    'Tez by Google',
  ];
  
  // Default Categories for Pakistani Users
  static const Map<String, List<String>> defaultCategories = {
    'Food & Dining': [
      'Groceries',
      'Restaurants',
      'Fast Food',
      'Bakery',
      'Fruits & Vegetables',
      'Meat & Poultry',
      'Dairy Products',
    ],
    'Transportation': [
      'Fuel/Petrol',
      'Public Transport',
      'Rickshaw/Taxi',
      'Car Maintenance',
      'Uber/Careem',
      'Parking',
      'Vehicle Insurance',
    ],
    'Utilities': [
      'Electricity (WAPDA/K-Electric)',
      'Gas (SSGC/SNGPL)',
      'Water',
      'Internet',
      'Mobile/Phone Bill',
      'Cable TV',
      'Waste Management',
    ],
    'Healthcare': [
      'Doctor Visits',
      'Medicines',
      'Hospital Bills',
      'Health Insurance',
      'Dental Care',
      'Lab Tests',
      'Medical Equipment',
    ],
    'Education': [
      'School Fees',
      'University Fees',
      'Books & Stationery',
      'Tuition',
      'Online Courses',
      'Educational Supplies',
    ],
    'Shopping': [
      'Clothing',
      'Electronics',
      'Home & Garden',
      'Personal Care',
      'Gifts',
      'Household Items',
    ],
    'Entertainment': [
      'Movies',
      'Sports',
      'Hobbies',
      'Subscriptions',
      'Games',
      'Events',
    ],
    'Religious': [
      'Zakat',
      'Sadaqah',
      'Mosque Donations',
      'Religious Books',
      'Hajj/Umrah',
    ],
    'Family': [
      'Child Care',
      'Elder Care',
      'Family Events',
      'Weddings',
      'Family Support',
    ],
    'Business': [
      'Office Supplies',
      'Business Meals',
      'Professional Services',
      'Marketing',
      'Equipment',
    ],
  };
}
