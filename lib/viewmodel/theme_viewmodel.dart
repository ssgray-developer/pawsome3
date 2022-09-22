import 'package:flutter/material.dart';
import 'package:pawsome/model/shared_preferences_methods/theme_preference.dart';

class ThemeViewModel extends ChangeNotifier {
  ThemePreference themePreference = ThemePreference();
  ThemeMode themeMode = ThemeMode.light;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    themePreference.setTheme(isOn);
    notifyListeners();
  }
}
