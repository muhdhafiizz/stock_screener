import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stock_screener/model/stock_chart_model.dart';
import '../repositories/stocks_chart_repositories.dart';

class StockChartProviders with ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  List<StockChartData> stockHistory = [];

  final Map<String, List<StockChartData>> _stockData = {};
  final StockChartRepository _repository;
  static const String boxName = "stock_chart_box";

  StockChartProviders(this._repository);

  bool hasDataFor(String symbol) {
    return _stockData.containsKey(symbol) && _stockData[symbol]!.isNotEmpty;
  }

  Future<void> fetchStockChart(String symbol) async {
    debugPrint("🚀 Fetching stock chart for $symbol");

    if (symbol == "N/A" || symbol.isEmpty) {
      debugPrint("🚫 Invalid stock symbol: $symbol. Skipping fetch.");
      return;
    }

    if (isLoading) {
      debugPrint("⚠️ Already loading, skipping fetch.");
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final box = await Hive.openBox<List>(boxName);

      if (box.containsKey(symbol)) {
        debugPrint("📦 Using cached data for $symbol");
        var cached = box.get(symbol);
        if (cached != null && cached.isNotEmpty) {
          stockHistory = cached.cast<StockChartData>();
          isLoading = false;
          notifyListeners();
          return;
        }
      }

      debugPrint("🌍 Calling repository to get data for $symbol...");
      List<StockChartData> fetchedData =
          await _repository.getStockHistory(symbol);

      if (fetchedData.isNotEmpty) {
        debugPrint("📈 Fetched ${fetchedData.length} data points for $symbol.");
        _stockData[symbol] = fetchedData;
        stockHistory = fetchedData;
        await box.put(symbol, stockHistory);
        debugPrint("✅ Stored in Hive for offline access.");
      } else {
        debugPrint("⚠️ No stock data returned from API.");
        stockHistory = [];
      }
    } catch (e) {
      debugPrint("❌ Error fetching stock data for $symbol: ${e.toString()}");
      errorMessage = "Failed to fetch data: ${e.toString()}";
      stockHistory = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
