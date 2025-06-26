class UserProfile {
  final String uid;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String currency;
  final String language;
  final bool isDarkMode;
  final bool biometricEnabled;
  final Map<String, dynamic>? preferences;

  UserProfile({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
    this.updatedAt,
    this.currency = 'PKR',
    this.language = 'English',
    this.isDarkMode = false,
    this.biometricEnabled = false,
    this.preferences,
  });

  UserProfile copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? currency,
    String? language,
    bool? isDarkMode,
    bool? biometricEnabled,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'currency': currency,
      'language': language,
      'isDarkMode': isDarkMode,
      'biometricEnabled': biometricEnabled,
      'preferences': preferences,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
      currency: map['currency'] ?? 'PKR',
      language: map['language'] ?? 'English',
      isDarkMode: map['isDarkMode'] ?? false,
      biometricEnabled: map['biometricEnabled'] ?? false,
      preferences: map['preferences'],
    );
  }

  @override
  String toString() {
    return 'UserProfile(uid: $uid, email: $email, fullName: $fullName, phoneNumber: $phoneNumber, profileImageUrl: $profileImageUrl, createdAt: $createdAt, updatedAt: $updatedAt, currency: $currency, language: $language, isDarkMode: $isDarkMode, biometricEnabled: $biometricEnabled, preferences: $preferences)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserProfile &&
      other.uid == uid &&
      other.email == email &&
      other.fullName == fullName &&
      other.phoneNumber == phoneNumber &&
      other.profileImageUrl == profileImageUrl &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.currency == currency &&
      other.language == language &&
      other.isDarkMode == isDarkMode &&
      other.biometricEnabled == biometricEnabled;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
      email.hashCode ^
      fullName.hashCode ^
      phoneNumber.hashCode ^
      profileImageUrl.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      currency.hashCode ^
      language.hashCode ^
      isDarkMode.hashCode ^
      biometricEnabled.hashCode;
  }
}
