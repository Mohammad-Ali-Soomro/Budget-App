// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AccountModelAdapter extends TypeAdapter<AccountModel> {
  @override
  final int typeId = 5;

  @override
  AccountModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AccountModel(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as AccountType,
      balance: fields[3] as double,
      currency: fields[4] as String,
      description: fields[5] as String?,
      bankName: fields[6] as String?,
      accountNumber: fields[7] as String?,
      cardNumber: fields[8] as String?,
      isDefault: fields[9] as bool,
      isActive: fields[10] as bool,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime?,
      color: fields[13] as int?,
      icon: fields[14] as String?,
      metadata: (fields[15] as Map?)?.cast<String, dynamic>(),
      userId: fields[16] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AccountModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.balance)
      ..writeByte(4)
      ..write(obj.currency)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.bankName)
      ..writeByte(7)
      ..write(obj.accountNumber)
      ..writeByte(8)
      ..write(obj.cardNumber)
      ..writeByte(9)
      ..write(obj.isDefault)
      ..writeByte(10)
      ..write(obj.isActive)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.color)
      ..writeByte(14)
      ..write(obj.icon)
      ..writeByte(15)
      ..write(obj.metadata)
      ..writeByte(16)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AccountTypeAdapter extends TypeAdapter<AccountType> {
  @override
  final int typeId = 4;

  @override
  AccountType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AccountType.cash;
      case 1:
        return AccountType.bank;
      case 2:
        return AccountType.creditCard;
      case 3:
        return AccountType.mobileWallet;
      case 4:
        return AccountType.investment;
      case 5:
        return AccountType.savings;
      default:
        return AccountType.cash;
    }
  }

  @override
  void write(BinaryWriter writer, AccountType obj) {
    switch (obj) {
      case AccountType.cash:
        writer.writeByte(0);
        break;
      case AccountType.bank:
        writer.writeByte(1);
        break;
      case AccountType.creditCard:
        writer.writeByte(2);
        break;
      case AccountType.mobileWallet:
        writer.writeByte(3);
        break;
      case AccountType.investment:
        writer.writeByte(4);
        break;
      case AccountType.savings:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
