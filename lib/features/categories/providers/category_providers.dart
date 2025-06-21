import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/hive_service.dart';
import '../data/models/category_model.dart';

// Categories Provider
final categoriesProvider = StateNotifierProvider<CategoriesNotifier, AsyncValue<List<CategoryModel>>>((ref) {
  return CategoriesNotifier();
});

class CategoriesNotifier extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  CategoriesNotifier() : super(const AsyncValue.loading()) {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categoryBox = HiveService.categoryBox;
      final categories = categoryBox.values.where((category) => category.isActive).toList();
      categories.sort((a, b) => a.name.compareTo(b.name));
      state = AsyncValue.data(categories);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      final categoryBox = HiveService.categoryBox;
      await categoryBox.put(category.id, category);
      await _loadCategories();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      final categoryBox = HiveService.categoryBox;
      await categoryBox.put(category.id, category);
      await _loadCategories();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      final categoryBox = HiveService.categoryBox;
      final category = categoryBox.get(categoryId);
      if (category != null && !category.isDefault) {
        final updatedCategory = category.copyWith(isActive: false);
        await categoryBox.put(categoryId, updatedCategory);
        await _loadCategories();
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void refresh() {
    _loadCategories();
  }
}

// Parent Categories Provider
final parentCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  final categories = ref.watch(categoriesProvider);
  return categories.when(
    data: (categoryList) => categoryList.where((category) => category.isParentCategory).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Subcategories Provider
final subcategoriesProvider = Provider.family<List<CategoryModel>, String>((ref, parentId) {
  final categories = ref.watch(categoriesProvider);
  return categories.when(
    data: (categoryList) => categoryList.where((category) => category.parentId == parentId).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Category by ID Provider
final categoryByIdProvider = Provider.family<CategoryModel?, String>((ref, categoryId) {
  final categories = ref.watch(categoriesProvider);
  return categories.when(
    data: (categoryList) => categoryList.firstWhere(
      (category) => category.id == categoryId,
      orElse: () => categoryList.first,
    ),
    loading: () => null,
    error: (_, __) => null,
  );
});

// Expense Categories Provider
final expenseCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  final categories = ref.watch(categoriesProvider);
  return categories.when(
    data: (categoryList) => categoryList.where((category) {
      // Filter categories typically used for expenses
      final expenseKeywords = ['food', 'transport', 'utilities', 'healthcare', 'shopping', 'entertainment'];
      return expenseKeywords.any((keyword) => category.name.toLowerCase().contains(keyword));
    }).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Income Categories Provider
final incomeCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  final categories = ref.watch(categoriesProvider);
  return categories.when(
    data: (categoryList) => categoryList.where((category) {
      // Filter categories typically used for income
      final incomeKeywords = ['salary', 'business', 'investment', 'freelance', 'bonus'];
      return incomeKeywords.any((keyword) => category.name.toLowerCase().contains(keyword)) ||
             category.name.toLowerCase().contains('income');
    }).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Default Categories Provider
final defaultCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  final categories = ref.watch(categoriesProvider);
  return categories.when(
    data: (categoryList) => categoryList.where((category) => category.isDefault).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Custom Categories Provider
final customCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  final categories = ref.watch(categoriesProvider);
  return categories.when(
    data: (categoryList) => categoryList.where((category) => !category.isDefault).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Category Creation Provider
final createCategoryProvider = Provider<Future<void> Function(CategoryModel)>((ref) {
  return (CategoryModel category) async {
    await ref.read(categoriesProvider.notifier).addCategory(category);
  };
});

// Category Update Provider
final updateCategoryProvider = Provider<Future<void> Function(CategoryModel)>((ref) {
  return (CategoryModel category) async {
    await ref.read(categoriesProvider.notifier).updateCategory(category);
  };
});

// Category Deletion Provider
final deleteCategoryProvider = Provider<Future<void> Function(String)>((ref) {
  return (String categoryId) async {
    await ref.read(categoriesProvider.notifier).deleteCategory(categoryId);
  };
});

// Helper function to create a new category
CategoryModel createNewCategory({
  required String name,
  required String icon,
  required int color,
  String? description,
  String? parentId,
}) {
  return CategoryModel(
    id: const Uuid().v4(),
    name: name,
    icon: icon,
    color: color,
    description: description,
    parentId: parentId,
    createdAt: DateTime.now(),
  );
}

// Helper function to get category hierarchy
String getCategoryHierarchy(CategoryModel category, List<CategoryModel> allCategories) {
  if (category.parentId == null) {
    return category.name;
  }
  
  final parent = allCategories.firstWhere(
    (c) => c.id == category.parentId,
    orElse: () => category,
  );
  
  return '${parent.name} > ${category.name}';
}
