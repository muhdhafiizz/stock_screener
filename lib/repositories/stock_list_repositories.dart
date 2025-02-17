import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import '../model/stock_listing_model.dart';

class StockRepository {
  static const String _apiKey = "EAQZ7IOMDAFSWIO4";
  static const String _baseUrl = "https://www.alphavantage.co/query";
  static const String _cacheBoxName = "stock_cache";

  late final Box<StockListing> _cacheBox;
  bool _rateLimitExceeded = false;
  bool get rateLimitExceeded => _rateLimitExceeded;

  StockRepository() {
    _cacheBox = Hive.box<StockListing>(_cacheBoxName);
  }

  Future<List<StockListing>?> fetchStockListings({String? date, String state = "active"}) async {
    if (_cacheBox.isNotEmpty) {
      debugPrint("📦 Using cached stock data");
      return _cacheBox.values.toList();
    }

    final uri = Uri.parse(
      "$_baseUrl?function=LISTING_STATUS&apikey=$_apiKey${date != null ? "&date=$date" : ""}&state=$state",
    );

    debugPrint("🌍 Fetching stock listings from: $uri");
    final response = await http.get(uri);

    _rateLimitExceeded = false; 
    
    debugPrint("📡 API Response Status: ${response.statusCode}");
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      if (response.body.trim().isEmpty || response.body == "{}") {
        debugPrint("⚠️ No data received from API.");
        return [];
      }

      if (jsonData.containsKey("Information") || (jsonData.containsKey("Note"))) {
        debugPrint("⚠️ API rate limit reached.");
        _rateLimitExceeded = true; 
        return null; 
      }

      try {
        List<List<dynamic>> csvData = const CsvToListConverter().convert(response.body);

        if (csvData.isEmpty || csvData.length == 1) {
          debugPrint("⚠️ Parsed CSV data is empty.");
          return [];
        }

        csvData.removeAt(0);
        List<StockListing> stocks = csvData
            .map((row) => StockListing.fromCsv(row.map((e) => e.toString()).toList()))
            .toList();

        debugPrint("✅ Successfully parsed ${stocks.length} stocks.");

        await _cacheBox.clear();
        for (var stock in stocks) {
          _cacheBox.put(stock.symbol, stock);
        }

        return stocks;
      } catch (e) {
        debugPrint("❌ CSV Parsing Error: $e");
        return [];
      }
    } else {
      debugPrint("❌ Failed to load stock listings. Status Code: ${response.statusCode}");
      throw Exception("Failed to load stock listings");
    }
  }
}
