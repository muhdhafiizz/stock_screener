import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../model/stock_listing_model.dart';
import '../repositories/stock_list_repositories.dart';

class StockProvider with ChangeNotifier {
  List<StockListing>? _stocks = []; 
  List<StockListing> _filteredStocks = [];
  bool _isLoading = false;
  bool _apiRateLimited = false;
  String? _errorMessage;
  late Box<StockListing> _stockBox;

  List<StockListing>? get stocks => _stocks;
  List<StockListing> get filteredStocks => _filteredStocks;
  bool get isLoading => _isLoading;
  bool get apiRateLimited => _apiRateLimited;
  String? get errorMessage => _errorMessage;

  Future<void> initBox() async {
    if (!Hive.isBoxOpen('stock_cache')) {
      _stockBox = await Hive.openBox<StockListing>('stock_cache');
    } else {
      _stockBox = Hive.box<StockListing>('stock_cache');
    }
  }

  Future<void> fetchStocks() async {
    _isLoading = true;
    _errorMessage = null;
    _apiRateLimited = false;
    notifyListeners();

    try {
      await initBox();

      if (_stockBox.isNotEmpty) {
        debugPrint("📦 Using cached stocks: ${_stockBox.values.toList()}");
        _stocks = _stockBox.values.toList();
        _filteredStocks = List.from(_stocks!); 
        _isLoading = false;
        notifyListeners();
        return;
      }

      debugPrint("🌍 Fetching new stock data...");

      StockRepository repository = StockRepository();
      _stocks = await repository.fetchStockListings();

      if (_stocks == null || _stocks!.isEmpty) {
        if (repository.rateLimitExceeded) {
          _apiRateLimited = true;
          _errorMessage = "API rate limit reached. Try again later.";
        } else {
          _errorMessage = "No stocks retrieved from API.";
        }
        debugPrint("⚠️ No stocks retrieved from API.");
      } else {
        debugPrint("✅ Stocks fetched: ${_stocks!.length}");

        await _stockBox.clear();
        await _stockBox.addAll(_stocks!);
        debugPrint("💾 Cached stocks saved.");
      }

      _filteredStocks = List.from(_stocks!);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("❌ Error: $_errorMessage");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchStock(String query) {
    if (query.isEmpty) {
      _filteredStocks = List.from(_stocks!);
    } else {
      _filteredStocks = _stocks!
          .where((stock) =>
              stock.name.toLowerCase().contains(query.toLowerCase()) ||
              stock.symbol.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}
