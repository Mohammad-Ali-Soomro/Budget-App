import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/theme_config.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/models/account_model.dart';
import '../../providers/account_providers.dart';

class AddAccountScreen extends ConsumerStatefulWidget {
  const AddAccountScreen({super.key});

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _descriptionController = TextEditingController();

  AccountType _selectedType = AccountType.bank;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _cardNumberController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to add accounts')),
        );
        return;
      }

      final account = createNewAccount(
        name: _nameController.text.trim(),
        type: _selectedType,
        initialBalance: double.tryParse(_balanceController.text) ?? 0.0,
        userId: currentUser.id,
        bankName: _bankNameController.text.trim().isNotEmpty
            ? _bankNameController.text.trim() : null,
        accountNumber: _accountNumberController.text.trim().isNotEmpty
            ? _accountNumberController.text.trim() : null,
        cardNumber: _cardNumberController.text.trim().isNotEmpty
            ? _cardNumberController.text.trim() : null,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim() : null,
      );

      await ref.read(accountsProvider.notifier).addAccount(account);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding account: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Account'),
        actions: [
          TextButton(
            onPressed: _saveAccount,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Account Name
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Account Name',
                        hintText: 'e.g., Main Checking',
                        prefixIcon: Icon(Icons.account_balance_wallet),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter account name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _balanceController,
                      decoration: const InputDecoration(
                        labelText: 'Initial Balance',
                        hintText: '0.00',
                        prefixIcon: Icon(Icons.attach_money),
                        suffixText: 'PKR',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Account Type
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Type',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<AccountType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: AccountType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getAccountTypeDisplayName(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAccountTypeDisplayName(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return 'Bank Account';
      case AccountType.cash:
        return 'Cash';
      case AccountType.creditCard:
        return 'Credit Card';
      case AccountType.savings:
        return 'Savings Account';
      case AccountType.investment:
        return 'Investment Account';
      case AccountType.mobileWallet:
        return 'Mobile Wallet';
    }
  }
}
