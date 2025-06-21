import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddBudgetScreen extends ConsumerWidget {
  const AddBudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Budget'),
      ),
      body: const Center(
        child: Text('Add Budget Screen - Coming Soon'),
      ),
    );
  }
}
