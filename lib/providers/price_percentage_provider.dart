import 'package:flutter/material.dart';
import '../model/price_percentage_model.dart';
import '../repositories/stock_price_repository.dart';

class StockPriceProvider with ChangeNotifier {
  final StockPriceRepository _repository;
  final Map<String, PricePercentageModel> _stockPrices = {};
  bool _isLoading = false;

  StockPriceProvider(this._repository);

  Map<String, PricePercentageModel> get stockPrices => _stockPrices;
  bool get isLoading => _isLoading;

  Future<void> fetchStockPrice(String symbol) async {
    _isLoading = true;
    notifyListeners();

    final stockData = await _repository.fetchStockPrice(symbol);
    
    if (stockData != null) {
      _stockPrices[symbol] = stockData;
    }

    _isLoading = false;
    notifyListeners();
  }
}
