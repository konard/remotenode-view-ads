// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      email: fields[1] as String?,
      username: fields[2] as String,
      isAnonymous: fields[3] as bool,
      coinBalance: fields[4] as int,
      totalEarned: fields[5] as int,
      totalWithdrawn: fields[6] as int,
      adsWatched: fields[7] as int,
      createdAt: fields[8] as DateTime,
      currentStreak: fields[9] as int,
      lastBonusClaim: fields[10] as DateTime?,
      rank: fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.isAnonymous)
      ..writeByte(4)
      ..write(obj.coinBalance)
      ..writeByte(5)
      ..write(obj.totalEarned)
      ..writeByte(6)
      ..write(obj.totalWithdrawn)
      ..writeByte(7)
      ..write(obj.adsWatched)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.currentStreak)
      ..writeByte(10)
      ..write(obj.lastBonusClaim)
      ..writeByte(11)
      ..write(obj.rank);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
