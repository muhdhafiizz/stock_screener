import 'package:flutter/material.dart';
import '../model/price_percentage_model.dart';
import '../repositories/stock_price_repository.dart';

class StockPriceProvider with ChangeNotifier {
  final StockPriceRepository _repository;
  final Map<String, PricePercentageModel> _stockPrices = {};
  final Set<String> _fetchingStocks = {}; // Track in-progress requests
  bool _isLoading = false;

  StockPriceProvider(this._repository);

  Map<String, PricePercentageModel> get stockPrices => _stockPrices;
  bool get isLoading => _isLoading;

  Future<void> fetchStockPrice(String symbol) async {
    if (_fetchingStocks.contains(symbol) || _stockPrices.containsKey(symbol)) {
      return; // Prevent duplicate requests
    }

    _fetchingStocks.add(symbol); // Mark as in-progress
    _isLoading = true;
    notifyListeners();

    try {
      final stockData = await _repository.fetchStockPrice(symbol);
      if (stockData != null) {
        _stockPrices[symbol] = stockData;
      }
    } finally {
      _fetchingStocks.remove(symbol); // Remove from in-progress
      _isLoading = false;
      notifyListeners();
    }
  }
}
