import 'package:hive/hive.dart';

part 'account_model.g.dart';

@HiveType(typeId: 4)
enum AccountType {
  @HiveField(0)
  cash,
  @HiveField(1)
  bank,
  @HiveField(2)
  creditCard,
  @HiveField(3)
  mobileWallet,
  @HiveField(4)
  investment,
  @HiveField(5)
  savings,
}

@HiveType(typeId: 5)
class AccountModel extends HiveObject {

  AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    this.description,
    this.bankName,
    this.accountNumber,
    this.cardNumber,
    this.isDefault = false,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.color,
    this.icon,
    this.metadata,
    required this.userId,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      name: json['name'],
      type: AccountType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AccountType.cash,
      ),
      balance: json['balance'].toDouble(),
      currency: json['currency'],
      description: json['description'],
      bankName: json['bankName'],
      accountNumber: json['accountNumber'],
      cardNumber: json['cardNumber'],
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      color: json['color'],
      icon: json['icon'],
      metadata: json['metadata'],
      userId: json['userId'] ?? '',
    );
  }
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final AccountType type;

  @HiveField(3)
  final double balance;

  @HiveField(4)
  final String currency;

  @HiveField(5)
  final String? description;

  @HiveField(6)
  final String? bankName;

  @HiveField(7)
  final String? accountNumber;

  @HiveField(8)
  final String? cardNumber;

  @HiveField(9)
  final bool isDefault;

  @HiveField(10)
  final bool isActive;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime? updatedAt;

  @HiveField(13)
  final int? color;

  @HiveField(14)
  final String? icon;

  @HiveField(15)
  final Map<String, dynamic>? metadata;

  @HiveField(16)
  final String userId; // User ID for data isolation

  AccountModel copyWith({
    String? id,
    String? name,
    AccountType? type,
    double? balance,
    String? currency,
    String? description,
    String? bankName,
    String? accountNumber,
    String? cardNumber,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? color,
    String? icon,
    Map<String, dynamic>? metadata,
    String? userId,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      cardNumber: cardNumber ?? this.cardNumber,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      color: color ?? this.color,
      icon: icon ?? this.icon,
      metadata: metadata ?? this.metadata,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'balance': balance,
      'currency': currency,
      'description': description,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'cardNumber': cardNumber,
      'isDefault': isDefault,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'color': color,
      'icon': icon,
      'metadata': metadata,
      'userId': userId,
    };
  }

  // Helper methods
  String get displayName {
    switch (type) {
      case AccountType.bank:
        return bankName != null ? '$name ($bankName)' : name;
      case AccountType.mobileWallet:
        return name;
      case AccountType.creditCard:
        return cardNumber != null ? '$name (...${cardNumber!.substring(cardNumber!.length - 4)})' : name;
      default:
        return name;
    }
  }

  String get formattedBalance {
    final sign = balance >= 0 ? '' : '-';
    return '$sign$currency ${balance.abs().toStringAsFixed(0)}';
  }

  String get typeDisplayName {
    switch (type) {
      case AccountType.cash:
        return 'Cash';
      case AccountType.bank:
        return 'Bank Account';
      case AccountType.creditCard:
        return 'Credit Card';
      case AccountType.mobileWallet:
        return 'Mobile Wallet';
      case AccountType.investment:
        return 'Investment';
      case AccountType.savings:
        return 'Savings';
    }
  }

  String get defaultIcon {
    switch (type) {
      case AccountType.cash:
        return '💵';
      case AccountType.bank:
        return '🏦';
      case AccountType.creditCard:
        return '💳';
      case AccountType.mobileWallet:
        return '📱';
      case AccountType.investment:
        return '📈';
      case AccountType.savings:
        return '🏛️';
    }
  }

  @override
  String toString() {
    return 'AccountModel(id: $id, name: $name, type: $type, balance: $balance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccountModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
