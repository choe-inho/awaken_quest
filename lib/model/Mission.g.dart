// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Mission.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MissionAdapter extends TypeAdapter<Mission> {
  @override
  final int typeId = 0;

  @override
  Mission read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Mission(
      id: fields[0] as int,
      title: fields[1] as String,
      unit: fields[2] as String,
      baseAmount: fields[3] as int,
      baseExp: fields[4] as int,
      hp: fields[5] as int,
      mp: fields[6] as int
    );
  }

  @override
  void write(BinaryWriter writer, Mission obj) {
    writer
      ..writeByte(7)  // 필드 7개 (id, title, unit, baseAmount, baseExp, hp, mp)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.baseAmount)
      ..writeByte(4)
      ..write(obj.baseExp)
      ..writeByte(5)
      ..write(obj.hp)
      ..writeByte(6)
      ..write(obj.mp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MissionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
