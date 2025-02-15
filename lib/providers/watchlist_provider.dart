import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../model/stock_listing_model.dart';

class WatchlistProvider with ChangeNotifier {
  late Box<StockListing> _watchlistBox;
  List<StockListing> _watchlist = [];

  WatchlistProvider() {
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    if (!Hive.isBoxOpen('watchlist_box')) {
      _watchlistBox = await Hive.openBox<StockListing>('watchlist_box');
    } else {
      _watchlistBox = Hive.box<StockListing>('watchlist_box');
    }

    _loadWatchlist();
  }

  void _loadWatchlist() {
    _watchlist = _watchlistBox.values.toList();
    notifyListeners();
  }

  List<StockListing> get watchlist => _watchlist;

  void addToWatchlist(StockListing stock) {
    if (!_watchlist.any((s) => s.symbol == stock.symbol)) {
      stock = StockListing(
          symbol: stock.symbol, name: stock.name, exchange: stock.exchange);
      _watchlistBox.put(
          stock.symbol, stock); 

      _watchlist = _watchlistBox.values.toList();
      notifyListeners();
    }
  }

  void removeFromWatchlist(String symbol) {
    _watchlistBox.delete(symbol); 
    _watchlist = _watchlistBox.values.toList();
    notifyListeners();
  }

  bool isInWatchlist(String symbol) {
    return _watchlistBox.containsKey(symbol);
  }
}
