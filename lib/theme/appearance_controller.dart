import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppearanceController extends ChangeNotifier {
  AppearanceController._();

  static final instance = AppearanceController._();
  static const _preferenceKey = 'appearance_mode';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    _themeMode = switch (preferences.getString(_preferenceKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_preferenceKey, mode.name);
  }
}
