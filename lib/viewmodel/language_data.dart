import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pawsome/model/shared_preferences_methods/language_preferences.dart';

import '../model/language_model.dart';

class LanguageData extends ChangeNotifier {
  LanguagePreference languagePreference = LanguagePreference();
  Language? languageType = Language.english;

  void changeLocale(BuildContext context, LanguageModel value) {
    languageType = value.type;
    context.setLocale(value.locale);
    languagePreference.setLanguage(value.text);

    notifyListeners();
  }
}
