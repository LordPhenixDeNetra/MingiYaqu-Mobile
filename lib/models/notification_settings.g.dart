// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationSettingsAdapter extends TypeAdapter<NotificationSettings> {
  @override
  final int typeId = 1;

  @override
  NotificationSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationSettings(
      isEnabled: fields[0] as bool,
      reminderDays: (fields[1] as List).cast<int>(),
      reminderHour: fields[2] as int,
      reminderMinute: fields[3] as int,
      soundEnabled: fields[4] as bool,
      vibrationEnabled: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationSettings obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.isEnabled)
      ..writeByte(1)
      ..write(obj.reminderDays)
      ..writeByte(2)
      ..write(obj.reminderHour)
      ..writeByte(3)
      ..write(obj.reminderMinute)
      ..writeByte(4)
      ..write(obj.soundEnabled)
      ..writeByte(5)
      ..write(obj.vibrationEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
