// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_percentage_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PricePercentageModelAdapter extends TypeAdapter<PricePercentageModel> {
  @override
  final int typeId = 3;

  @override
  PricePercentageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PricePercentageModel(
      symbol: fields[0] as String,
      price: fields[1] as double,
      changePercent: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, PricePercentageModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.price)
      ..writeByte(2)
      ..write(obj.changePercent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PricePercentageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
