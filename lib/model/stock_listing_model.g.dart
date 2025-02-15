// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_listing_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockListingAdapter extends TypeAdapter<StockListing> {
  @override
  final int typeId = 0;

  @override
  StockListing read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockListing(
      symbol: fields[0] as String,
      name: fields[1] as String,
      exchange: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, StockListing obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.exchange);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockListingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
