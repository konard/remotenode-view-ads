// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 3;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.adReward;
      case 1:
        return TransactionType.dailyBonus;
      case 2:
        return TransactionType.streakBonus;
      case 3:
        return TransactionType.withdrawal;
      case 4:
        return TransactionType.referralBonus;
      default:
        return TransactionType.adReward;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.adReward:
        writer.writeByte(0);
        break;
      case TransactionType.dailyBonus:
        writer.writeByte(1);
        break;
      case TransactionType.streakBonus:
        writer.writeByte(2);
        break;
      case TransactionType.withdrawal:
        writer.writeByte(3);
        break;
      case TransactionType.referralBonus:
        writer.writeByte(4);
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

class CoinTransactionAdapter extends TypeAdapter<CoinTransaction> {
  @override
  final int typeId = 4;

  @override
  CoinTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoinTransaction(
      id: fields[0] as String,
      type: fields[1] as TransactionType,
      amount: fields[2] as int,
      description: fields[3] as String,
      createdAt: fields[4] as DateTime,
      relatedId: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CoinTransaction obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.relatedId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoinTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
