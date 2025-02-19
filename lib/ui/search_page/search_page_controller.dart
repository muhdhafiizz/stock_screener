import 'package:flutter/material.dart';
import '../../model/stock_listing_model.dart';
import '../../repositories/stock_list_repositories.dart';


class SearchProvider with ChangeNotifier {
  final StockRepository _repository = StockRepository();
  
  final TextEditingController searchController = TextEditingController();
  List<StockListing>? _allStocks = [];
  List<StockListing>? _filteredStocks = [];

  List<StockListing>? get filteredStocks => _filteredStocks;

  SearchProvider() {
    _loadStocks();
    searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadStocks() async {
    _allStocks = await _repository.fetchStockListings();
    _filteredStocks = _allStocks;
    notifyListeners();
  }

  Future<void> refreshStocks() async {
    await _loadStocks();
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();
    _filteredStocks = _allStocks?.where((stock) {
      return stock.name.toLowerCase().contains(query) ||
             stock.symbol.toLowerCase().contains(query);
    }).toList();
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
