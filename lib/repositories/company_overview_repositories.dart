import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/company_overview_model.dart';

class CompanyRepository {
  static const String _apiKey = "EAQZ7IOMDAFSWIO4";
  static const String _baseUrl = "https://www.alphavantage.co/query";

  bool _rateLimitExceeded = false;

  bool get rateLimitExceeded => _rateLimitExceeded;

  Future<CompanyOverview?> fetchCompanyOverview(String symbol) async {
    final uri =
        Uri.parse("$_baseUrl?function=OVERVIEW&symbol=$symbol&apikey=$_apiKey");

    debugPrint("API Request URL: $uri");

    final response = await http.get(uri);

    debugPrint("API Response Status: ${response.statusCode}");
    debugPrint("API Response Body: ${response.body}");

    _rateLimitExceeded = false; 

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData.containsKey("Information") || (jsonData.containsKey("Note"))) {
        debugPrint("⚠️ API rate limit reached.");
        _rateLimitExceeded = true; 
        return null;
      }

      if (jsonData.isEmpty || jsonData.containsKey("Error Message")) {
        debugPrint("❌ No company data found for symbol: $symbol");
        return null;
      }

      return CompanyOverview.fromJson(jsonData);
    } else {
      debugPrint("❌ Failed to fetch data for symbol: $symbol");
      return null;
    }
  }
}
