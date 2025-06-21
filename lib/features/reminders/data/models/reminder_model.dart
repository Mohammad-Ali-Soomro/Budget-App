import 'package:hive/hive.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 10)
enum ReminderFrequency {
  @HiveField(0)
  once,
  @HiveField(1)
  daily,
  @HiveField(2)
  weekly,
  @HiveField(3)
  monthly,
  @HiveField(4)
  quarterly,
  @HiveField(5)
  yearly,
}

@HiveType(typeId: 11)
class ReminderModel extends HiveObject {

  ReminderModel({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.dueDate,
    required this.frequency,
    this.categoryId,
    this.accountId,
    this.isActive = true,
    this.isPaid = false,
    this.paidDate,
    required this.createdAt,
    this.updatedAt,
    this.notificationId,
    this.reminderDaysBefore = 3,
    this.notes,
    this.metadata,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      amount: json['amount'].toDouble(),
      dueDate: DateTime.parse(json['dueDate']),
      frequency: ReminderFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => ReminderFrequency.monthly,
      ),
      categoryId: json['categoryId'],
      accountId: json['accountId'],
      isActive: json['isActive'] ?? true,
      isPaid: json['isPaid'] ?? false,
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      notificationId: json['notificationId'],
      reminderDaysBefore: json['reminderDaysBefore'] ?? 3,
      notes: json['notes'],
      metadata: json['metadata'],
    );
  }
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final DateTime dueDate;

  @HiveField(5)
  final ReminderFrequency frequency;

  @HiveField(6)
  final String? categoryId;

  @HiveField(7)
  final String? accountId;

  @HiveField(8)
  final bool isActive;

  @HiveField(9)
  final bool isPaid;

  @HiveField(10)
  final DateTime? paidDate;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime? updatedAt;

  @HiveField(13)
  final int? notificationId;

  @HiveField(14)
  final int reminderDaysBefore;

  @HiveField(15)
  final String? notes;

  @HiveField(16)
  final Map<String, dynamic>? metadata;

  ReminderModel copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    DateTime? dueDate,
    ReminderFrequency? frequency,
    String? categoryId,
    String? accountId,
    bool? isActive,
    bool? isPaid,
    DateTime? paidDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? notificationId,
    int? reminderDaysBefore,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      frequency: frequency ?? this.frequency,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      isActive: isActive ?? this.isActive,
      isPaid: isPaid ?? this.isPaid,
      paidDate: paidDate ?? this.paidDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      notificationId: notificationId ?? this.notificationId,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'frequency': frequency.name,
      'categoryId': categoryId,
      'accountId': accountId,
      'isActive': isActive,
      'isPaid': isPaid,
      'paidDate': paidDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'notificationId': notificationId,
      'reminderDaysBefore': reminderDaysBefore,
      'notes': notes,
      'metadata': metadata,
    };
  }

  // Helper methods
  bool get isOverdue => DateTime.now().isAfter(dueDate) && !isPaid;
  bool get isDueToday => DateTime.now().day == dueDate.day && 
                        DateTime.now().month == dueDate.month && 
                        DateTime.now().year == dueDate.year;
  bool get isDueSoon => DateTime.now().difference(dueDate).inDays.abs() <= reminderDaysBefore;

  String get formattedAmount => 'Rs. ${amount.toStringAsFixed(0)}';

  String get frequencyDisplayName {
    switch (frequency) {
      case ReminderFrequency.once:
        return 'One Time';
      case ReminderFrequency.daily:
        return 'Daily';
      case ReminderFrequency.weekly:
        return 'Weekly';
      case ReminderFrequency.monthly:
        return 'Monthly';
      case ReminderFrequency.quarterly:
        return 'Quarterly';
      case ReminderFrequency.yearly:
        return 'Yearly';
    }
  }

  int get daysUntilDue {
    final now = DateTime.now();
    return dueDate.difference(now).inDays;
  }

  String get statusText {
    if (isPaid) return 'Paid';
    if (isOverdue) return 'Overdue';
    if (isDueToday) return 'Due Today';
    if (isDueSoon) return 'Due Soon';
    return 'Upcoming';
  }

  DateTime get nextDueDate {
    if (frequency == ReminderFrequency.once) return dueDate;
    
    final now = DateTime.now();
    DateTime next = dueDate;
    
    while (next.isBefore(now)) {
      switch (frequency) {
        case ReminderFrequency.daily:
          next = next.add(const Duration(days: 1));
          break;
        case ReminderFrequency.weekly:
          next = next.add(const Duration(days: 7));
          break;
        case ReminderFrequency.monthly:
          next = DateTime(next.year, next.month + 1, next.day);
          break;
        case ReminderFrequency.quarterly:
          next = DateTime(next.year, next.month + 3, next.day);
          break;
        case ReminderFrequency.yearly:
          next = DateTime(next.year + 1, next.month, next.day);
          break;
        case ReminderFrequency.once:
          break;
      }
    }
    
    return next;
  }

  @override
  String toString() {
    return 'ReminderModel(id: $id, title: $title, amount: $amount, dueDate: $dueDate, frequency: $frequency)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReminderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
