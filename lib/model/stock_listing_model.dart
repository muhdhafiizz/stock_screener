import 'package:hive/hive.dart';

part 'stock_listing_model.g.dart';

@HiveType(typeId: 0)
class StockListing extends HiveObject {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String exchange;


  StockListing({required this.symbol, required this.name, required this.exchange});

  factory StockListing.fromCsv(List<String> csv) {
    return StockListing(
      symbol: csv[0],
      name: csv[1],
      exchange: csv[2],
    );
  }
}

