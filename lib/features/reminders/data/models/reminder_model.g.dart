// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderModelAdapter extends TypeAdapter<ReminderModel> {
  @override
  final int typeId = 11;

  @override
  ReminderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReminderModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      amount: fields[3] as double,
      dueDate: fields[4] as DateTime,
      frequency: fields[5] as ReminderFrequency,
      categoryId: fields[6] as String?,
      accountId: fields[7] as String?,
      isActive: fields[8] as bool,
      isPaid: fields[9] as bool,
      paidDate: fields[10] as DateTime?,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime?,
      notificationId: fields[13] as int?,
      reminderDaysBefore: fields[14] as int,
      notes: fields[15] as String?,
      metadata: (fields[16] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ReminderModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.frequency)
      ..writeByte(6)
      ..write(obj.categoryId)
      ..writeByte(7)
      ..write(obj.accountId)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.isPaid)
      ..writeByte(10)
      ..write(obj.paidDate)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.notificationId)
      ..writeByte(14)
      ..write(obj.reminderDaysBefore)
      ..writeByte(15)
      ..write(obj.notes)
      ..writeByte(16)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReminderFrequencyAdapter extends TypeAdapter<ReminderFrequency> {
  @override
  final int typeId = 10;

  @override
  ReminderFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReminderFrequency.once;
      case 1:
        return ReminderFrequency.daily;
      case 2:
        return ReminderFrequency.weekly;
      case 3:
        return ReminderFrequency.monthly;
      case 4:
        return ReminderFrequency.quarterly;
      case 5:
        return ReminderFrequency.yearly;
      default:
        return ReminderFrequency.once;
    }
  }

  @override
  void write(BinaryWriter writer, ReminderFrequency obj) {
    switch (obj) {
      case ReminderFrequency.once:
        writer.writeByte(0);
        break;
      case ReminderFrequency.daily:
        writer.writeByte(1);
        break;
      case ReminderFrequency.weekly:
        writer.writeByte(2);
        break;
      case ReminderFrequency.monthly:
        writer.writeByte(3);
        break;
      case ReminderFrequency.quarterly:
        writer.writeByte(4);
        break;
      case ReminderFrequency.yearly:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
