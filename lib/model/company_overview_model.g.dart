// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_overview_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompanyOverviewAdapter extends TypeAdapter<CompanyOverview> {
  @override
  final int typeId = 1;

  @override
  CompanyOverview read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompanyOverview(
      symbol: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      sector: fields[3] as String,
      marketCap: fields[4] as String,
      weeksLow: fields[5] as String,
      weeksHigh: fields[6] as String,
      dividendYield: fields[7] as String,
      currency: fields[8] as String,
      earningPerShare: fields[9] as String,
      country: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CompanyOverview obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.sector)
      ..writeByte(4)
      ..write(obj.marketCap)
      ..writeByte(5)
      ..write(obj.weeksLow)
      ..writeByte(6)
      ..write(obj.weeksHigh)
      ..writeByte(7)
      ..write(obj.dividendYield)
      ..writeByte(8)
      ..write(obj.currency)
      ..writeByte(9)
      ..write(obj.earningPerShare)
      ..writeByte(10)
      ..write(obj.country);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyOverviewAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
