import 'package:shared_preferences/shared_preferences.dart';

class LanguagePreference {
  static const language = 'LANGUAGE';

  void setLanguage(String value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(language, value);
  }

  Future<String> getLanguage() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(language) ?? 'English';
  }
}