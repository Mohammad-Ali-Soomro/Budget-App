import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur')
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Budget Manager PK'**
  String get appName;

  /// Dashboard tab label
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Transactions tab label
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// Budgets tab label
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// Goals tab label
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Total balance label
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Add income button label
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get addIncome;

  /// Add expense button label
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// Set budget button label
  ///
  /// In en, this message translates to:
  /// **'Set Budget'**
  String get setBudget;

  /// Add goal button label
  ///
  /// In en, this message translates to:
  /// **'Add Goal'**
  String get addGoal;

  /// Recent transactions section title
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// Spending overview chart title
  ///
  /// In en, this message translates to:
  /// **'Spending Overview'**
  String get spendingOverview;

  /// Budget overview section title
  ///
  /// In en, this message translates to:
  /// **'Budget Overview'**
  String get budgetOverview;

  /// View all button label
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Empty state message for transactions
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// Empty state description for transactions
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first transaction'**
  String get startByAddingTransaction;

  /// Empty state message for budgets
  ///
  /// In en, this message translates to:
  /// **'No budgets set'**
  String get noBudgetsSet;

  /// Empty state description for budgets
  ///
  /// In en, this message translates to:
  /// **'Create your first budget to track spending'**
  String get createFirstBudget;

  /// Income transaction type
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// Expense transaction type
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// Transfer transaction type
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// Amount field label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Category field label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Account field label
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Date field label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Notes field label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Cash account type
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// Bank account type
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bank;

  /// Mobile wallet account type
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get mobile;

  /// Credit card account type
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// Today date label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Yesterday date label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// This week date range
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// This month date range
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// This year date range
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// Weekly budget period
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// Monthly budget period
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// Quarterly budget period
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get quarterly;

  /// Yearly budget period
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// Active status
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Completed status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Paused status
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// Cancelled status
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// Budget exceeded status
  ///
  /// In en, this message translates to:
  /// **'Exceeded'**
  String get exceeded;

  /// Budget near limit status
  ///
  /// In en, this message translates to:
  /// **'Near Limit'**
  String get nearLimit;

  /// Budget on track status
  ///
  /// In en, this message translates to:
  /// **'On Track'**
  String get onTrack;

  /// Dark mode setting
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Currency setting
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// Notifications setting
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Backup setting
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// Export data option
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// Import data option
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// About section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// App version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Morning greeting
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// Afternoon greeting
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// Evening greeting
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// Financial tip section title
  ///
  /// In en, this message translates to:
  /// **'Financial Tip'**
  String get financialTip;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Personal information section
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// Update profile description
  ///
  /// In en, this message translates to:
  /// **'Update your profile details'**
  String get updateProfileDetails;

  /// Security settings section
  ///
  /// In en, this message translates to:
  /// **'Security Settings'**
  String get securitySettings;

  /// Security settings description
  ///
  /// In en, this message translates to:
  /// **'Change password and security options'**
  String get changePasswordSecurity;

  /// Notification preferences section
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notificationPreferences;

  /// Notification settings description
  ///
  /// In en, this message translates to:
  /// **'Manage your notification settings'**
  String get manageNotificationSettings;

  /// Currency and language section
  ///
  /// In en, this message translates to:
  /// **'Currency & Language'**
  String get currencyLanguage;

  /// Currency language description
  ///
  /// In en, this message translates to:
  /// **'Set your preferred currency and language'**
  String get setPreferredCurrencyLanguage;

  /// Data and privacy section
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get dataPrivacy;

  /// Export data option
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// Export data description
  ///
  /// In en, this message translates to:
  /// **'Download your financial data'**
  String get downloadFinancialData;

  /// Backup and sync section
  ///
  /// In en, this message translates to:
  /// **'Backup & Sync'**
  String get backupSync;

  /// Backup sync description
  ///
  /// In en, this message translates to:
  /// **'Manage data backup and synchronization'**
  String get manageDataBackupSync;

  /// Privacy policy section
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Privacy policy description
  ///
  /// In en, this message translates to:
  /// **'Read our privacy policy'**
  String get readPrivacyPolicy;

  /// Sign out button
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Sign out confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmation;

  /// Financial summary section
  ///
  /// In en, this message translates to:
  /// **'Financial Summary'**
  String get financialSummary;

  /// Account management section
  ///
  /// In en, this message translates to:
  /// **'Account Management'**
  String get accountManagement;

  /// Active budgets label
  ///
  /// In en, this message translates to:
  /// **'Active Budgets'**
  String get activeBudgets;

  /// Monthly income label
  ///
  /// In en, this message translates to:
  /// **'Monthly Income'**
  String get monthlyIncome;

  /// Monthly expenses label
  ///
  /// In en, this message translates to:
  /// **'Monthly Expenses'**
  String get monthlyExpenses;

  /// Spent amount label
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// Budget amount label
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// Remaining amount label
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// Over budget message
  ///
  /// In en, this message translates to:
  /// **'Over budget by'**
  String get overBudgetBy;

  /// Normal budget status
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// Live data freshness
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// Recent data freshness
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// Stale data freshness
  ///
  /// In en, this message translates to:
  /// **'Stale'**
  String get stale;

  /// Old data freshness
  ///
  /// In en, this message translates to:
  /// **'Old'**
  String get old;

  /// Unknown data freshness
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Data freshness indicator
  ///
  /// In en, this message translates to:
  /// **'Data Freshness'**
  String get dataFreshness;

  /// Last updated label
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastUpdated;

  /// Empty state message for budgets
  ///
  /// In en, this message translates to:
  /// **'No Budgets Yet'**
  String get noBudgetsYet;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'ur':
      return SUr();
  }

  throw FlutterError(
      'S.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
