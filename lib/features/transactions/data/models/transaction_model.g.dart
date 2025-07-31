// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 2;

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionModel(
      id: fields[0] as String? ?? '',
      amount: fields[1] as double? ?? 0.0,
      description: fields[2] as String? ?? '',
      type: fields[3] as TransactionType? ?? TransactionType.expense,
      categoryId: fields[4] as String? ?? '',
      accountId: fields[5] as String? ?? '',
      toAccountId: fields[6] as String?,
      date: fields[7] as DateTime? ?? DateTime.now(),
      createdAt: fields[8] as DateTime? ?? DateTime.now(),
      updatedAt: fields[9] as DateTime?,
      notes: fields[10] as String?,
      imagePath: fields[11] as String?,
      metadata: (fields[12] as Map?)?.cast<String, dynamic>(),
      isRecurring: fields[13] as bool? ?? false,
      recurringId: fields[14] as String?,
      location: fields[15] as String?,
      tags: (fields[16] as List?)?.cast<String>(),
      userId: fields[17] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.categoryId)
      ..writeByte(5)
      ..write(obj.accountId)
      ..writeByte(6)
      ..write(obj.toAccountId)
      ..writeByte(7)
      ..write(obj.date)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.imagePath)
      ..writeByte(12)
      ..write(obj.metadata)
      ..writeByte(13)
      ..write(obj.isRecurring)
      ..writeByte(14)
      ..write(obj.recurringId)
      ..writeByte(15)
      ..write(obj.location)
      ..writeByte(16)
      ..write(obj.tags)
      ..writeByte(17)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 1;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.income;
      case 1:
        return TransactionType.expense;
      case 2:
        return TransactionType.transfer;
      default:
        return TransactionType.income;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.income:
        writer.writeByte(0);
        break;
      case TransactionType.expense:
        writer.writeByte(1);
        break;
      case TransactionType.transfer:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
