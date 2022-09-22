import 'dart:ui';

enum Language { chinese, english }

class LanguageModel {
  final Language type;
  final String text;
  final Locale locale;

  LanguageModel(this.type, this.text, this.locale);
}
