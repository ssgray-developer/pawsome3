// ignore_for_file: constant_identifier_names

import 'dart:ui';

enum LanguageType {
  ENGLISH,
  CHINESE,
}

const String CHINESE = "zh";
const String ENGLISH = "en";
const String ASSETS_PATH_LOCALISATIONS = "assets/translations";
const Locale CHINESE_LOCAL = Locale("zh", "CN");
const Locale ENGLISH_LOCAL = Locale("en", "US");

extension LanguageTypeExtension on LanguageType {
  String getValue() {
    switch (this) {
      case LanguageType.ENGLISH:
        return ENGLISH;
      case LanguageType.CHINESE:
        return CHINESE;
    }
  }
}
