import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../model/company_overview_model.dart';
import '../repositories/company_overview_repositories.dart';

class CompanyProvider with ChangeNotifier {
  final CompanyRepository _repository = CompanyRepository();
  Box<CompanyOverview>? _companyBox;

  bool _isLoading = false;
  String? _errorMessage;
  bool _apiRateLimited = false;
  CompanyOverview? _company;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get apiRateLimited => _apiRateLimited;
  CompanyOverview? get company => _company;

  Future<void> _initBox() async {
    if (_companyBox == null) {
      if (!Hive.isBoxOpen('company_cache')) {
        _companyBox = await Hive.openBox<CompanyOverview>('company_cache');
      } else {
        _companyBox = Hive.box<CompanyOverview>('company_cache');
      }
    }
  }

  Future<void> loadCompanyOverview(String symbol) async {
    _isLoading = true;
    _errorMessage = null;
    _apiRateLimited = false;
    notifyListeners();

    await _initBox();

    final cachedData = _companyBox?.get(symbol);
    if (cachedData != null) {
      debugPrint("✅ Loaded from cache for symbol: $symbol");
      _company = cachedData;
      _isLoading = false;
      notifyListeners();
      return;
    }

    debugPrint("📡 Fetching data from API for symbol: $symbol");
    final result = await _repository.fetchCompanyOverview(symbol);

    if (result == null) {
      if (_repository.rateLimitExceeded) {
        _apiRateLimited = true;
        _errorMessage = "API rate limit reached. Try again later.";
      } else {
        _errorMessage = "No company overview found.";
      }
      _company = null;
    } else {
      _company = result;
      _errorMessage = null;

      await _companyBox?.put(symbol, result);
      debugPrint("💾 Cached data for symbol: $symbol");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearCache() async {
    await _initBox();
    await _companyBox?.clear();
    debugPrint("🗑 Cache cleared.");
  }
}
