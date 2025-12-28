// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ad.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AdTypeAdapter extends TypeAdapter<AdType> {
  @override
  final int typeId = 1;

  @override
  AdType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AdType.video;
      case 1:
        return AdType.image;
      case 2:
        return AdType.playable;
      default:
        return AdType.video;
    }
  }

  @override
  void write(BinaryWriter writer, AdType obj) {
    switch (obj) {
      case AdType.video:
        writer.writeByte(0);
        break;
      case AdType.image:
        writer.writeByte(1);
        break;
      case AdType.playable:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AdAdapter extends TypeAdapter<Ad> {
  @override
  final int typeId = 2;

  @override
  Ad read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ad(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as AdType,
      mediaUrl: fields[4] as String,
      thumbnailUrl: fields[5] as String,
      minWatchTimeSeconds: fields[6] as int,
      maxWatchTimeSeconds: fields[7] as int,
      advertiser: fields[8] as String,
      createdAt: fields[9] as DateTime,
      isWatched: fields[10] as bool,
      userRating: fields[11] as int?,
      userComment: fields[12] as String?,
      earnedCoins: fields[13] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Ad obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.mediaUrl)
      ..writeByte(5)
      ..write(obj.thumbnailUrl)
      ..writeByte(6)
      ..write(obj.minWatchTimeSeconds)
      ..writeByte(7)
      ..write(obj.maxWatchTimeSeconds)
      ..writeByte(8)
      ..write(obj.advertiser)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.isWatched)
      ..writeByte(11)
      ..write(obj.userRating)
      ..writeByte(12)
      ..write(obj.userComment)
      ..writeByte(13)
      ..write(obj.earnedCoins);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
