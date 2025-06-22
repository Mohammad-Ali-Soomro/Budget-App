import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/config/theme_config.dart';
import '../../data/models/transaction_model.dart';
import '../../../transactions/providers/transaction_providers.dart';
import '../../../categories/providers/category_providers.dart';
import '../../../accounts/providers/account_providers.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  
  const AddTransactionScreen({
    super.key,
    this.initialType,
  });
  final TransactionType? initialType;

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  
  TransactionType _selectedType = TransactionType.expense;
  String? _selectedCategoryId;
  String? _selectedAccountId;
  String? _selectedToAccountId;
  DateTime _selectedDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ref.watch(categoriesProvider);
    final accounts = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        actions: [
          TextButton(
            onPressed: _saveTransaction,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Type Selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction Type',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _TypeButton(
                              type: TransactionType.income,
                              isSelected: _selectedType == TransactionType.income,
                              onTap: () => setState(() => _selectedType = TransactionType.income),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _TypeButton(
                              type: TransactionType.expense,
                              isSelected: _selectedType == TransactionType.expense,
                              onTap: () => setState(() => _selectedType = TransactionType.expense),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _TypeButton(
                              type: TransactionType.transfer,
                              isSelected: _selectedType == TransactionType.transfer,
                              onTap: () => setState(() => _selectedType = TransactionType.transfer),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Amount Field
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          prefixText: 'Rs. ',
                          hintText: '0',
                        ),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Description Field
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: 'Enter description',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Category Selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      categories.when(
                        data: (categoryList) => DropdownButtonFormField<String>(
                          value: _selectedCategoryId,
                          decoration: const InputDecoration(
                            hintText: 'Select category',
                          ),
                          items: categoryList.map((category) {
                            return DropdownMenuItem(
                              value: category.id,
                              child: Row(
                                children: [
                                  Text(category.icon, style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Text(category.name),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const Text('Error loading categories'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Account Selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedType == TransactionType.transfer ? 'From Account' : 'Account',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      accounts.when(
                        data: (accountList) => DropdownButtonFormField<String>(
                          value: _selectedAccountId,
                          decoration: const InputDecoration(
                            hintText: 'Select account',
                          ),
                          items: accountList.map((account) {
                            return DropdownMenuItem(
                              value: account.id,
                              child: Row(
                                children: [
                                  Text(account.defaultIcon, style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Text(account.displayName),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedAccountId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select an account';
                            }
                            return null;
                          },
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const Text('Error loading accounts'),
                      ),
                    ],
                  ),
                ),
              ),

              // To Account Selector (for transfers)
              if (_selectedType == TransactionType.transfer) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'To Account',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        accounts.when(
                          data: (accountList) => DropdownButtonFormField<String>(
                            value: _selectedToAccountId,
                            decoration: const InputDecoration(
                              hintText: 'Select destination account',
                            ),
                            items: accountList
                                .where((account) => account.id != _selectedAccountId)
                                .map((account) {
                              return DropdownMenuItem(
                                value: account.id,
                                child: Row(
                                  children: [
                                    Text(account.defaultIcon, style: const TextStyle(fontSize: 20)),
                                    const SizedBox(width: 8),
                                    Text(account.displayName),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedToAccountId = value;
                              });
                            },
                            validator: (value) {
                              if (_selectedType == TransactionType.transfer && value == null) {
                                return 'Please select destination account';
                              }
                              return null;
                            },
                          ),
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) => const Text('Error loading accounts'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Date Selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _selectDate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(PhosphorIcons.calendar()),
                              const SizedBox(width: 8),
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Notes Field
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes (Optional)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Add notes...',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
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
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final transaction = createNewTransaction(
        amount: double.parse(_amountController.text),
        description: _descriptionController.text,
        type: _selectedType,
        categoryId: _selectedCategoryId!,
        accountId: _selectedAccountId!,
        toAccountId: _selectedToAccountId,
        date: _selectedDate,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      await ref.read(createTransactionProvider)(transaction);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction added successfully')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }
}

class _TypeButton extends StatelessWidget {

  const _TypeButton({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });
  final TransactionType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color color;
    IconData icon;
    String label;
    
    switch (type) {
      case TransactionType.income:
        color = ThemeConfig.primaryGreen;
        icon = PhosphorIcons.plus();
        label = 'Income';
        break;
      case TransactionType.expense:
        color = ThemeConfig.accentRed;
        icon = PhosphorIcons.minus();
        label = 'Expense';
        break;
      case TransactionType.transfer:
        color = ThemeConfig.secondaryBlue;
        icon = PhosphorIcons.arrowsLeftRight();
        label = 'Transfer';
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? color : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
