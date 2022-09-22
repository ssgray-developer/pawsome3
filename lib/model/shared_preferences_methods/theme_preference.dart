import 'package:shared_preferences/shared_preferences.dart';

class ThemePreference {
  static const darkMode = 'DARKMODE';

  void setTheme(bool value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool(darkMode, value);
  }

  Future<bool> getTheme() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(darkMode) ?? false;
  }
}
