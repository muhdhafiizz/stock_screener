// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_chart_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockChartDataAdapter extends TypeAdapter<StockChartData> {
  @override
  final int typeId = 2;

  @override
  StockChartData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockChartData(
      date: fields[0] as String,
      closingPrice: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, StockChartData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.closingPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockChartDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
