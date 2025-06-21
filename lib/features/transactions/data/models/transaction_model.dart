import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 1)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
  @HiveField(2)
  transfer,
}

@HiveType(typeId: 2)
class TransactionModel extends HiveObject {

  TransactionModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.type,
    required this.categoryId,
    required this.accountId,
    this.toAccountId,
    required this.date,
    required this.createdAt,
    this.updatedAt,
    this.notes,
    this.imagePath,
    this.metadata,
    this.isRecurring = false,
    this.recurringId,
    this.location,
    this.tags,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      categoryId: json['categoryId'],
      accountId: json['accountId'],
      toAccountId: json['toAccountId'],
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      notes: json['notes'],
      imagePath: json['imagePath'],
      metadata: json['metadata'],
      isRecurring: json['isRecurring'] ?? false,
      recurringId: json['recurringId'],
      location: json['location'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final TransactionType type;

  @HiveField(4)
  final String categoryId;

  @HiveField(5)
  final String accountId;

  @HiveField(6)
  final String? toAccountId; // For transfers

  @HiveField(7)
  final DateTime date;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime? updatedAt;

  @HiveField(10)
  final String? notes;

  @HiveField(11)
  final String? imagePath;

  @HiveField(12)
  final Map<String, dynamic>? metadata;

  @HiveField(13)
  final bool isRecurring;

  @HiveField(14)
  final String? recurringId;

  @HiveField(15)
  final String? location;

  @HiveField(16)
  final List<String>? tags;

  TransactionModel copyWith({
    String? id,
    double? amount,
    String? description,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    String? toAccountId,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    String? imagePath,
    Map<String, dynamic>? metadata,
    bool? isRecurring,
    String? recurringId,
    String? location,
    List<String>? tags,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      metadata: metadata ?? this.metadata,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringId: recurringId ?? this.recurringId,
      location: location ?? this.location,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'type': type.name,
      'categoryId': categoryId,
      'accountId': accountId,
      'toAccountId': toAccountId,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'notes': notes,
      'imagePath': imagePath,
      'metadata': metadata,
      'isRecurring': isRecurring,
      'recurringId': recurringId,
      'location': location,
      'tags': tags,
    };
  }

  // Helper methods
  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
  bool get isTransfer => type == TransactionType.transfer;

  String get formattedAmount {
    final sign = isExpense ? '-' : '+';
    return '$sign Rs. ${amount.toStringAsFixed(0)}';
  }

  String get displayAmount {
    return 'Rs. ${amount.toStringAsFixed(0)}';
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, amount: $amount, type: $type, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
