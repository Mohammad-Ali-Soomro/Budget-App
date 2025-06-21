import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profileImagePath,
    this.currency = 'PKR',
    this.language = 'en',
    this.isDarkMode = false,
    this.isNotificationsEnabled = true,
    this.isBiometricEnabled = false,
    required this.createdAt,
    this.updatedAt,
    this.preferences,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profileImagePath: json['profileImagePath'],
      currency: json['currency'] ?? 'PKR',
      language: json['language'] ?? 'en',
      isDarkMode: json['isDarkMode'] ?? false,
      isNotificationsEnabled: json['isNotificationsEnabled'] ?? true,
      isBiometricEnabled: json['isBiometricEnabled'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      preferences: json['preferences'],
    );
  }
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? phoneNumber;

  @HiveField(4)
  final String? profileImagePath;

  @HiveField(5)
  final String currency;

  @HiveField(6)
  final String language;

  @HiveField(7)
  final bool isDarkMode;

  @HiveField(8)
  final bool isNotificationsEnabled;

  @HiveField(9)
  final bool isBiometricEnabled;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime? updatedAt;

  @HiveField(12)
  final Map<String, dynamic>? preferences;

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImagePath,
    String? currency,
    String? language,
    bool? isDarkMode,
    bool? isNotificationsEnabled,
    bool? isBiometricEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isNotificationsEnabled: isNotificationsEnabled ?? this.isNotificationsEnabled,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImagePath': profileImagePath,
      'currency': currency,
      'language': language,
      'isDarkMode': isDarkMode,
      'isNotificationsEnabled': isNotificationsEnabled,
      'isBiometricEnabled': isBiometricEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'preferences': preferences,
    };
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, currency: $currency, language: $language)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
