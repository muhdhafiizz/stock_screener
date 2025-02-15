import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../model/stock_chart_model.dart';
import 'package:http/http.dart' as http;

class StockChartRepository {
  static const String baseUrl = "https://www.alphavantage.co/query";
  static const String apiKey = "HHGX00PZKIFHQMAV"; 
  static const String boxName = "stock_chart_box";

  Future<List<StockChartData>> getStockHistory(String symbol) async {
    debugPrint("🌍 Fetching stock history for: $symbol");

    final box = await Hive.openBox<List>(boxName);

    if (box.containsKey(symbol)) {
      final cachedData = box.get(symbol)!.cast<StockChartData>();
      debugPrint("📦 Loaded ${cachedData.length} cached data points for $symbol.");
      return cachedData;
    }

    final url = Uri.parse("$baseUrl?function=TIME_SERIES_MONTHLY&symbol=$symbol&apikey=$apiKey");
    debugPrint("Request URL: $url");

    final response = await http.get(url);
    debugPrint("Response Status Code: ${response.statusCode}");

    if (response.statusCode != 200) {
      debugPrint("❌ Failed to fetch stock data: ${response.body}");
      throw Exception("Failed to fetch stock data");
    }

    final decodedData = json.decode(response.body);

    if (!decodedData.containsKey("Monthly Time Series")) {
      debugPrint("⚠️ No 'Monthly Time Series' found in API response.");
      return [];
    }

    final timeSeries = decodedData["Monthly Time Series"] as Map<String, dynamic>;

    final stockData = timeSeries.entries.map((entry) {
      return StockChartData.fromJson(entry.key, entry.value);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    await box.put(symbol, stockData);
    debugPrint("✅ Cached ${stockData.length} data points for $symbol.");

    return stockData;
  }
}
