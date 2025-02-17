import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../model/price_percentage_model.dart';

class StockPriceRepository {
  static const String _apiKey = "EAQZ7IOMDAFSWIO4";
  static const Duration cacheDuration = Duration(minutes: 5);

  Future<PricePercentageModel?> fetchStockPrice(String symbol) async {
    if (!Hive.isBoxOpen('stock_prices_cache')) {
      await Hive.openBox('stock_prices_cache');
    }

    final Box stockBox = Hive.box('stock_prices_cache');

    // Check cache first
    final String? cachedData = stockBox.get("stock_$symbol");
    final int? cachedTime = stockBox.get("stock_time_$symbol");

    if (cachedData != null && cachedTime != null) {
      final DateTime lastFetch = DateTime.fromMillisecondsSinceEpoch(cachedTime);
      if (DateTime.now().difference(lastFetch) < cacheDuration) {
        return PricePercentageModel.fromJson(json.decode(cachedData));
      }
    }

    final url = "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$_apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["Global Quote"] != null) {
          final stockData = PricePercentageModel.fromJson(data);

          await stockBox.put("stock_$symbol", json.encode(data));
          await stockBox.put("stock_time_$symbol", DateTime.now().millisecondsSinceEpoch);

          return stockData;
        }
      }
    } catch (error) {
      print("Error fetching stock price: $error");
    }

    return null;
  }
}
