// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xp_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class XPTransactionAdapter extends TypeAdapter<XPTransaction> {
  @override
  final int typeId = 10;

  @override
  XPTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return XPTransaction(
      id: fields[0] as String,
      amount: fields[1] as int,
      reason: fields[2] as String,
      type: fields[3] as String,
      timestamp: fields[4] as DateTime,
      relatedId: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, XPTransaction obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.reason)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.relatedId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XPTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
