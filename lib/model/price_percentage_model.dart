import 'package:hive/hive.dart';

part 'price_percentage_model.g.dart';

@HiveType(typeId: 3)
class PricePercentageModel {
  @HiveField(0)
  final String symbol;
  @HiveField(1)
  final double price;
  @HiveField(2)
  final double changePercent;

  PricePercentageModel({
    required this.symbol,
    required this.price,
    required this.changePercent,
  });

  factory PricePercentageModel.fromJson(Map<String, dynamic> json) {
    final quote = json["Global Quote"];
    return PricePercentageModel(
      symbol: quote["01. symbol"],
      price: double.tryParse(quote["05. price"] ?? "0") ?? 0.0,
      changePercent: double.tryParse(
              quote["10. change percent"]?.replaceAll("%", "") ?? "0") ??
          0.0,
    );
  }
}
