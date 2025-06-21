import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

void main() {
  runApp(const BudgetApp());
}

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget App Pakistan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.light,
        ),
      ),
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

// Dashboard Screen
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    const Text(
                      'PKR 125,000',
                      style: TextStyle(
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
                            const Text('PKR 85,000', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(PhosphorIcons.arrowDown(), color: Colors.red),
                            const Text('Expenses'),
                            const Text('PKR 45,000', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick Actions
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
                      onTap: () {},
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
                      onTap: () {},
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
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: Icon(PhosphorIcons.arrowUp(), color: Colors.green),
                    ),
                    title: const Text('Salary'),
                    subtitle: const Text('Monthly Income'),
                    trailing: const Text(
                      '+PKR 75,000',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.shade100,
                      child: Icon(PhosphorIcons.shoppingCart(), color: Colors.red),
                    ),
                    title: const Text('Groceries'),
                    subtitle: const Text('Food & Dining'),
                    trailing: const Text(
                      '-PKR 8,500',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: Icon(PhosphorIcons.car(), color: Colors.orange),
                    ),
                    title: const Text('Fuel'),
                    subtitle: const Text('Transportation'),
                    trailing: const Text(
                      '-PKR 12,000',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Transactions Screen
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.funnel()),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(PhosphorIcons.trendUp(), color: Colors.green, size: 32),
                        const SizedBox(height: 8),
                        const Text('Total Income'),
                        const Text(
                          'PKR 85,000',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(PhosphorIcons.trendDown(), color: Colors.red, size: 32),
                        const SizedBox(height: 8),
                        const Text('Total Expenses'),
                        const Text(
                          'PKR 45,000',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Transactions List
          const Text(
            'All Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Transaction Items
          Card(
            child: Column(
              children: [
                _buildTransactionTile(
                  'Salary Payment',
                  'Income • Bank Account',
                  '+PKR 75,000',
                  Colors.green,
                  PhosphorIcons.money(),
                  'Today',
                ),
                const Divider(height: 1),
                _buildTransactionTile(
                  'Grocery Shopping',
                  'Food & Dining • Cash',
                  '-PKR 8,500',
                  Colors.red,
                  PhosphorIcons.shoppingCart(),
                  'Yesterday',
                ),
                const Divider(height: 1),
                _buildTransactionTile(
                  'Fuel/Petrol',
                  'Transportation • Debit Card',
                  '-PKR 12,000',
                  Colors.red,
                  PhosphorIcons.car(),
                  '2 days ago',
                ),
                const Divider(height: 1),
                _buildTransactionTile(
                  'Electricity Bill',
                  'Utilities • Bank Transfer',
                  '-PKR 6,500',
                  Colors.red,
                  PhosphorIcons.lightbulb(),
                  '3 days ago',
                ),
                const Divider(height: 1),
                _buildTransactionTile(
                  'Freelance Work',
                  'Income • Bank Account',
                  '+PKR 25,000',
                  Colors.green,
                  PhosphorIcons.laptop(),
                  '5 days ago',
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(PhosphorIcons.plus()),
      ),
    );
  }

  Widget _buildTransactionTile(
    String title,
    String subtitle,
    String amount,
    Color amountColor,
    IconData icon,
    String date,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: amountColor.withOpacity(0.1),
        child: Icon(icon, color: amountColor),
      ),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          Text(
            date,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      trailing: Text(
        amount,
        style: TextStyle(
          color: amountColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

// Budgets Screen
class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Monthly Budget Overview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Budget Overview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Budget: PKR 50,000'),
                      Text(
                        'Spent: PKR 32,000',
                        style: TextStyle(color: Colors.orange.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.64,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Remaining: PKR 18,000',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Category Budgets
          const Text(
            'Category Budgets',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _buildBudgetCategory(
            'Food & Dining',
            'PKR 15,000',
            'PKR 8,500',
            0.57,
            Colors.orange,
            PhosphorIcons.forkKnife(),
          ),
          const SizedBox(height: 12),

          _buildBudgetCategory(
            'Transportation',
            'PKR 12,000',
            'PKR 12,000',
            1.0,
            Colors.red,
            PhosphorIcons.car(),
          ),
          const SizedBox(height: 12),

          _buildBudgetCategory(
            'Utilities',
            'PKR 8,000',
            'PKR 6,500',
            0.81,
            Colors.orange,
            PhosphorIcons.lightbulb(),
          ),
          const SizedBox(height: 12),

          _buildBudgetCategory(
            'Entertainment',
            'PKR 5,000',
            'PKR 2,000',
            0.4,
            Colors.green,
            PhosphorIcons.gameController(),
          ),
          const SizedBox(height: 12),

          _buildBudgetCategory(
            'Healthcare',
            'PKR 10,000',
            'PKR 3,000',
            0.3,
            Colors.green,
            PhosphorIcons.heartbeat(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(PhosphorIcons.plus()),
      ),
    );
  }

  Widget _buildBudgetCategory(
    String category,
    String budget,
    String spent,
    double progress,
    Color progressColor,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: progressColor.withOpacity(0.1),
                  child: Icon(icon, color: progressColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Budget: $budget'),
                    ],
                  ),
                ),
                Text(
                  spent,
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
              '${(progress * 100).toInt()}% used',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Accounts Screen
class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Total Balance Card
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
                  const Text(
                    'PKR 125,000',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Accounts List
          const Text(
            'Your Accounts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _buildAccountCard(
            'HBL Bank Account',
            'PKR 85,000',
            'Bank Account',
            PhosphorIcons.bank(),
            Colors.blue,
          ),
          const SizedBox(height: 12),

          _buildAccountCard(
            'Cash Wallet',
            'PKR 25,000',
            'Cash',
            PhosphorIcons.wallet(),
            Colors.green,
          ),
          const SizedBox(height: 12),

          _buildAccountCard(
            'JazzCash Mobile Wallet',
            'PKR 15,000',
            'Mobile Wallet',
            PhosphorIcons.deviceMobile(),
            Colors.orange,
          ),
          const SizedBox(height: 12),

          _buildAccountCard(
            'Savings Account',
            'PKR 0',
            'Savings',
            PhosphorIcons.piggyBank(),
            Colors.purple,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(PhosphorIcons.plus()),
      ),
    );
  }

  Widget _buildAccountCard(
    String name,
    String balance,
    String type,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(type),
        trailing: Text(
          balance,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () {},
      ),
    );
  }
}

// Settings Screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    backgroundColor: Colors.green.shade100,
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
                          'Muhammad Ali',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ali@example.com',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Icon(PhosphorIcons.pencil(), color: Colors.grey),
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

          _buildSettingsTile(
            'Currency',
            'Pakistani Rupee (PKR)',
            PhosphorIcons.currencyDollar(),
          ),
          _buildSettingsTile(
            'Language',
            'English',
            PhosphorIcons.translate(),
          ),
          _buildSettingsTile(
            'Notifications',
            'Enabled',
            PhosphorIcons.bell(),
          ),
          _buildSettingsTile(
            'Dark Mode',
            'Disabled',
            PhosphorIcons.moon(),
          ),

          const SizedBox(height: 20),
          const Text(
            'Data & Privacy',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _buildSettingsTile(
            'Export Data',
            'Download your data',
            PhosphorIcons.export(),
          ),
          _buildSettingsTile(
            'Import Data',
            'Import from file',
            PhosphorIcons.upload(),
          ),
          _buildSettingsTile(
            'Backup & Sync',
            'Cloud backup',
            PhosphorIcons.cloudArrowUp(),
          ),

          const SizedBox(height: 20),
          const Text(
            'Support',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _buildSettingsTile(
            'Help & Support',
            'Get help',
            PhosphorIcons.question(),
          ),
          _buildSettingsTile(
            'About',
            'App version 1.0.0',
            PhosphorIcons.info(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(String title, String subtitle, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(PhosphorIcons.caretRight()),
        onTap: () {},
      ),
    );
  }
}
