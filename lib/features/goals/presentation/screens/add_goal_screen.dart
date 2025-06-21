import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddGoalScreen extends ConsumerWidget {
  const AddGoalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Goal'),
      ),
      body: const Center(
        child: Text('Add Goal Screen - Coming Soon'),
      ),
    );
  }
}
