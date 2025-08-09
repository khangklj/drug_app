import 'package:flutter/material.dart';

class ThemeManager with ChangeNotifier {
  bool _isDarkTheme = false;

  ThemeMode get themeMode => _isDarkTheme ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
  }
}
