import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 6)
enum BudgetPeriod {
  @HiveField(0)
  weekly,
  @HiveField(1)
  monthly,
  @HiveField(2)
  quarterly,
  @HiveField(3)
  yearly,
}

@HiveType(typeId: 7)
class BudgetModel extends HiveObject {

  BudgetModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.amount,
    this.spent = 0.0,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.alertEnabled = true,
    this.alertThreshold = 0.8, // 80% by default
    required this.createdAt,
    this.updatedAt,
    this.description,
    this.metadata,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'],
      name: json['name'],
      categoryId: json['categoryId'],
      amount: json['amount'].toDouble(),
      spent: json['spent']?.toDouble() ?? 0.0,
      period: BudgetPeriod.values.firstWhere(
        (e) => e.name == json['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isActive: json['isActive'] ?? true,
      alertEnabled: json['alertEnabled'] ?? true,
      alertThreshold: json['alertThreshold']?.toDouble() ?? 0.8,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      description: json['description'],
      metadata: json['metadata'],
    );
  }
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String categoryId;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final double spent;

  @HiveField(5)
  final BudgetPeriod period;

  @HiveField(6)
  final DateTime startDate;

  @HiveField(7)
  final DateTime endDate;

  @HiveField(8)
  final bool isActive;

  @HiveField(9)
  final bool alertEnabled;

  @HiveField(10)
  final double alertThreshold; // Percentage (0.0 to 1.0)

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime? updatedAt;

  @HiveField(13)
  final String? description;

  @HiveField(14)
  final Map<String, dynamic>? metadata;

  BudgetModel copyWith({
    String? id,
    String? name,
    String? categoryId,
    double? amount,
    double? spent,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    bool? alertEnabled,
    double? alertThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      alertEnabled: alertEnabled ?? this.alertEnabled,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'amount': amount,
      'spent': spent,
      'period': period.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'alertEnabled': alertEnabled,
      'alertThreshold': alertThreshold,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'description': description,
      'metadata': metadata,
    };
  }

  // Helper methods
  double get remaining => amount - spent;
  double get percentage => amount > 0 ? (spent / amount).clamp(0.0, 1.0) : 0.0;
  bool get isExceeded => spent > amount;
  bool get isNearLimit => percentage >= alertThreshold;
  bool get isExpired => DateTime.now().isAfter(endDate);

  String get formattedAmount => 'Rs. ${amount.toStringAsFixed(0)}';
  String get formattedSpent => 'Rs. ${spent.toStringAsFixed(0)}';
  String get formattedRemaining => 'Rs. ${remaining.toStringAsFixed(0)}';

  String get periodDisplayName {
    switch (period) {
      case BudgetPeriod.weekly:
        return 'Weekly';
      case BudgetPeriod.monthly:
        return 'Monthly';
      case BudgetPeriod.quarterly:
        return 'Quarterly';
      case BudgetPeriod.yearly:
        return 'Yearly';
    }
  }

  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  String get statusText {
    if (isExpired) return 'Expired';
    if (isExceeded) return 'Exceeded';
    if (isNearLimit) return 'Near Limit';
    return 'On Track';
  }

  @override
  String toString() {
    return 'BudgetModel(id: $id, name: $name, amount: $amount, spent: $spent, period: $period)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BudgetModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
