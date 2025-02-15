
import 'package:hive/hive.dart';

part 'stock_chart_model.g.dart';


@HiveType(typeId: 2)
class StockChartData extends HiveObject {

  @HiveField(0)
  final String date;

  @HiveField(1)
  final double closingPrice;

  StockChartData({required this.date, required this.closingPrice});

  factory StockChartData.fromJson(String date, Map<String, dynamic> data) {
    return StockChartData(
      date: date,
      closingPrice: double.parse(data["4. close"]),
    );
  }
}
