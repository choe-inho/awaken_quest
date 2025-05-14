// lib/model/Title_Model.g.dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Title_Model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TitleModelAdapter extends TypeAdapter<TitleModel> {
  @override
  final int typeId = 1;

  @override
  TitleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TitleModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      rarity: fields[3] as int,
      conditionType: fields[4] as String,
      conditionValue: fields[5] as int,
      colorHex: fields[6] as String,
      hasEffect: fields[7] as bool,
      acquiredAt: fields[8] as DateTime?,
      iconPath: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TitleModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.rarity)
      ..writeByte(4)
      ..write(obj.conditionType)
      ..writeByte(5)
      ..write(obj.conditionValue)
      ..writeByte(6)
      ..write(obj.colorHex)
      ..writeByte(7)
      ..write(obj.hasEffect)
      ..writeByte(8)
      ..write(obj.acquiredAt)
      ..writeByte(9)
      ..write(obj.iconPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TitleModelAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}