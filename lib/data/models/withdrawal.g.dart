// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdrawal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WithdrawalStatusAdapter extends TypeAdapter<WithdrawalStatus> {
  @override
  final int typeId = 5;

  @override
  WithdrawalStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WithdrawalStatus.pending;
      case 1:
        return WithdrawalStatus.approved;
      case 2:
        return WithdrawalStatus.rejected;
      default:
        return WithdrawalStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, WithdrawalStatus obj) {
    switch (obj) {
      case WithdrawalStatus.pending:
        writer.writeByte(0);
        break;
      case WithdrawalStatus.approved:
        writer.writeByte(1);
        break;
      case WithdrawalStatus.rejected:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WithdrawalStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WithdrawalAdapter extends TypeAdapter<Withdrawal> {
  @override
  final int typeId = 6;

  @override
  Withdrawal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Withdrawal(
      id: fields[0] as String,
      coinAmount: fields[1] as int,
      usdAmount: fields[2] as double,
      paypalEmail: fields[3] as String,
      status: fields[4] as WithdrawalStatus,
      createdAt: fields[5] as DateTime,
      processedAt: fields[6] as DateTime?,
      rejectionReason: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Withdrawal obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.coinAmount)
      ..writeByte(2)
      ..write(obj.usdAmount)
      ..writeByte(3)
      ..write(obj.paypalEmail)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.processedAt)
      ..writeByte(7)
      ..write(obj.rejectionReason);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WithdrawalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
