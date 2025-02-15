import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../model/price_percentage_model.dart';

class StockPriceProvider with ChangeNotifier {
  final Map<String, PricePercentageModel> _stockPrices = {};
  static const String _apiKey = "EAQZ7IOMDAFSWIO4";
  static const Duration cacheDuration = Duration(minutes: 5);
  bool _isLoading = false;

  Map<String, PricePercentageModel> get stockPrices => _stockPrices;
  bool get isLoading => _isLoading;

  Future<void> fetchStockPrice(String symbol) async {
    _isLoading = true;
    notifyListeners(); 

    if (!Hive.isBoxOpen('stock_prices_cache')) {
      await Hive.openBox('stock_prices_cache');
    }

    final Box stockBox = Hive.box('stock_prices_cache');

    final String? cachedData = stockBox.get("stock_$symbol");
    final int? cachedTime = stockBox.get("stock_time_$symbol");

    if (cachedData != null && cachedTime != null) {
      final DateTime lastFetch =
          DateTime.fromMillisecondsSinceEpoch(cachedTime);
      if (DateTime.now().difference(lastFetch) < cacheDuration) {
        _stockPrices[symbol] =
            PricePercentageModel.fromJson(json.decode(cachedData));
        _isLoading = false;
        notifyListeners();
        return;
      }
    }

    final url =
        "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$_apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["Global Quote"] != null) {
          final stockData = PricePercentageModel.fromJson(data);
          _stockPrices[symbol] = stockData;

          await stockBox.put("stock_$symbol", json.encode(data));
          await stockBox.put(
              "stock_time_$symbol", DateTime.now().millisecondsSinceEpoch);
        }
      }
    } catch (error) {
      debugPrint("Error fetching stock price: $error");
    } finally {
      _isLoading = false; 
      notifyListeners();
    }
  }
}
