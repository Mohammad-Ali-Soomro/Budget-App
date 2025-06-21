import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 3)
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String icon;

  @HiveField(3)
  final int color;

  @HiveField(4)
  final String? description;

  @HiveField(5)
  final String? parentId;

  @HiveField(6)
  final bool isDefault;

  @HiveField(7)
  final bool isActive;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime? updatedAt;

  @HiveField(10)
  final double? budgetLimit;

  @HiveField(11)
  final Map<String, dynamic>? metadata;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.description,
    this.parentId,
    this.isDefault = false,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.budgetLimit,
    this.metadata,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    int? color,
    String? description,
    String? parentId,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? budgetLimit,
    Map<String, dynamic>? metadata,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      budgetLimit: budgetLimit ?? this.budgetLimit,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'description': description,
      'parentId': parentId,
      'isDefault': isDefault,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'budgetLimit': budgetLimit,
      'metadata': metadata,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      color: json['color'],
      description: json['description'],
      parentId: json['parentId'],
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      budgetLimit: json['budgetLimit']?.toDouble(),
      metadata: json['metadata'],
    );
  }

  // Helper methods
  bool get isParentCategory => parentId == null;
  bool get isSubCategory => parentId != null;
  bool get hasBudgetLimit => budgetLimit != null && budgetLimit! > 0;

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, isDefault: $isDefault, parentId: $parentId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
