import 'package:hive/hive.dart';

part 'company_overview_model.g.dart';

@HiveType(typeId: 1)
class CompanyOverview extends HiveObject {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String sector;

  @HiveField(4)
  final String marketCap;

  @HiveField(5)
  final String weeksLow;

  @HiveField(6)
  final String weeksHigh;

  @HiveField(7)
  final String dividendYield;

  @HiveField(8)
  final String currency;

  @HiveField(9)
  final String earningPerShare;

  @HiveField(10)
  final String country;

  CompanyOverview({
    required this.symbol,
    required this.name,
    required this.description,
    required this.sector,
    required this.marketCap,
    required this.weeksLow,
    required this.weeksHigh,
    required this.dividendYield,
    required this.currency,
    required this.earningPerShare,
    required this.country
  });

  factory CompanyOverview.fromJson(Map<String, dynamic> json) {
    return CompanyOverview(
      symbol: (json["Symbol"] ?? "N/A").toString(),
      name: (json["Name"] ?? "N/A").toString(),
      description: (json["Description"] ?? "No description available").toString(),
      sector: (json["Sector"] ?? "N/A").toString(),
      marketCap: (json["MarketCapitalization"] ?? "N/A").toString(),
      weeksLow: (json["52WeekLow"] ?? "N/A").toString(),
      weeksHigh: (json["52WeekHigh"] ?? "N/A").toString(),
      dividendYield: (json["DividendYield"] ?? "N/A").toString(),
      currency: (json["Currency"] ?? "N/A").toString(),
      earningPerShare: (json["EPS"] ?? "N/A").toString(),
      country: (json["Country"] ?? "N/A").toString(),

    );
  }
}
