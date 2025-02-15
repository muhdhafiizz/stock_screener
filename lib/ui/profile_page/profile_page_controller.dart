import 'package:flutter/material.dart';

class ProfileController with ChangeNotifier {
  Locale _locale = const Locale("en");

  Locale get locale => _locale;

  void switchLanguage(int index) {
    _locale = index == 0 ? const Locale("en") : const Locale("ms");
    notifyListeners();
  }
}
