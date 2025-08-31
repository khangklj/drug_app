import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ScanningModes { camera, gallery, both }

class SettingsManager with ChangeNotifier {
  bool _isDarkTheme = false;
  ScanningModes _scanningMode = ScanningModes.both;

  bool get isDarkTheme => _isDarkTheme;
  ThemeMode get themeMode => _isDarkTheme ? ThemeMode.dark : ThemeMode.light;
  ScanningModes get scanningMode => _scanningMode;

  Future<void> initSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    _scanningMode = ScanningModes.values[prefs.getInt('scanningMode') ?? 2];
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    _isDarkTheme = !_isDarkTheme;
    await prefs.setBool('isDarkTheme', _isDarkTheme);
    notifyListeners();
  }

  Future<void> toogleScanningOptions(ScanningModes options) async {
    if (options == _scanningMode) return;
    final prefs = await SharedPreferences.getInstance();
    _scanningMode = options;
    await prefs.setInt('scanningMode', _scanningMode.index);
    notifyListeners();
  }
}
