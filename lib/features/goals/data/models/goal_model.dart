import 'package:hive/hive.dart';

part 'goal_model.g.dart';

@HiveType(typeId: 8)
enum GoalStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  completed,
  @HiveField(2)
  paused,
  @HiveField(3)
  cancelled,
}

@HiveType(typeId: 9)
class GoalModel extends HiveObject {

  GoalModel({
    required this.id,
    required this.name,
    required this.description,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
    this.status = GoalStatus.active,
    this.categoryId,
    this.accountId,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.imagePath,
    this.color,
    this.icon,
    this.monthlyTarget,
    this.reminderEnabled = true,
    this.metadata,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      targetAmount: json['targetAmount'].toDouble(),
      currentAmount: json['currentAmount']?.toDouble() ?? 0.0,
      targetDate: DateTime.parse(json['targetDate']),
      status: GoalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GoalStatus.active,
      ),
      categoryId: json['categoryId'],
      accountId: json['accountId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      imagePath: json['imagePath'],
      color: json['color'],
      icon: json['icon'],
      monthlyTarget: json['monthlyTarget']?.toDouble(),
      reminderEnabled: json['reminderEnabled'] ?? true,
      metadata: json['metadata'],
    );
  }
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double targetAmount;

  @HiveField(4)
  final double currentAmount;

  @HiveField(5)
  final DateTime targetDate;

  @HiveField(6)
  final GoalStatus status;

  @HiveField(7)
  final String? categoryId;

  @HiveField(8)
  final String? accountId;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime? updatedAt;

  @HiveField(11)
  final DateTime? completedAt;

  @HiveField(12)
  final String? imagePath;

  @HiveField(13)
  final int? color;

  @HiveField(14)
  final String? icon;

  @HiveField(15)
  final double? monthlyTarget;

  @HiveField(16)
  final bool reminderEnabled;

  @HiveField(17)
  final Map<String, dynamic>? metadata;

  GoalModel copyWith({
    String? id,
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    GoalStatus? status,
    String? categoryId,
    String? accountId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    String? imagePath,
    int? color,
    String? icon,
    double? monthlyTarget,
    bool? reminderEnabled,
    Map<String, dynamic>? metadata,
  }) {
    return GoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      completedAt: completedAt ?? this.completedAt,
      imagePath: imagePath ?? this.imagePath,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      monthlyTarget: monthlyTarget ?? this.monthlyTarget,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
      'status': status.name,
      'categoryId': categoryId,
      'accountId': accountId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'imagePath': imagePath,
      'color': color,
      'icon': icon,
      'monthlyTarget': monthlyTarget,
      'reminderEnabled': reminderEnabled,
      'metadata': metadata,
    };
  }

  // Helper methods
  double get remaining => targetAmount - currentAmount;
  double get percentage => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  bool get isCompleted => status == GoalStatus.completed || currentAmount >= targetAmount;
  bool get isActive => status == GoalStatus.active;
  bool get isOverdue => DateTime.now().isAfter(targetDate) && !isCompleted;

  String get formattedTargetAmount => 'Rs. ${targetAmount.toStringAsFixed(0)}';
  String get formattedCurrentAmount => 'Rs. ${currentAmount.toStringAsFixed(0)}';
  String get formattedRemaining => 'Rs. ${remaining.toStringAsFixed(0)}';

  String get statusDisplayName {
    switch (status) {
      case GoalStatus.active:
        return 'Active';
      case GoalStatus.completed:
        return 'Completed';
      case GoalStatus.paused:
        return 'Paused';
      case GoalStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(targetDate)) return 0;
    return targetDate.difference(now).inDays;
  }

  double get suggestedMonthlyAmount {
    if (monthlyTarget != null) return monthlyTarget!;
    
    final now = DateTime.now();
    final monthsRemaining = ((targetDate.year - now.year) * 12 + targetDate.month - now.month).clamp(1, 120);
    return remaining / monthsRemaining;
  }

  String get progressText {
    if (isCompleted) return 'Goal Achieved! 🎉';
    if (isOverdue) return 'Overdue';
    if (daysRemaining <= 30) return '$daysRemaining days left';
    return '${(daysRemaining / 30).ceil()} months left';
  }

  @override
  String toString() {
    return 'GoalModel(id: $id, name: $name, targetAmount: $targetAmount, currentAmount: $currentAmount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GoalModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
