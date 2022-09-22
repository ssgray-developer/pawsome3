import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pawsome/configuration/configuration.dart';
import 'package:pawsome/model/language_model.dart';
import 'package:pawsome/viewmodel/language_data.dart';
import 'package:provider/provider.dart';

import '../resources/strings_manager.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageData = Provider.of<LanguageData>(context);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(AppStrings.selectLanguage).tr(),
      ),
      body: ListView.separated(
        itemCount: languageList.length,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (BuildContext context, int index) {
          final language = languageList[index];
          return RadioListTile<Language>(
              title: Text(language.text),
              value: language.type,
              groupValue: languageData.languageType,
              controlAffinity: ListTileControlAffinity.trailing,
              onChanged: (Language? value) {
                languageData.changeLocale(context, language);
              });
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }
}
