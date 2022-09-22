import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:pawsome/resources/strings_manager.dart';
import 'package:pawsome/view/language.dart';
import 'package:pawsome/view/personal_info.dart';
import 'package:pawsome/viewmodel/theme_viewmodel.dart';
import 'package:pawsome/viewmodel/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/language_model.dart';
import '../viewmodel/language_data.dart';
import '../widget/custom_list_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> launchEmail() async {
    const url = 'mailto:ssgray.developer@gmail.com';

    Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeViewModel = Provider.of<ThemeViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => ZoomDrawer.of(context)!.toggle(),
        ),
        title: const Text(AppStrings.settings).tr(),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            Text(
              AppStrings.account.tr(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 10,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.orange.shade50,
                child: const Icon(
                  Icons.person,
                  color: Colors.orange,
                ),
              ),
              title: Text(
                Provider.of<UserViewModel>(context).getUser.username,
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: const Text(AppStrings.personalInfo).tr(),
              trailing: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const PersonalInfoScreen()));
                },
                child: Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: themeViewModel.isDarkMode
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade200,
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color:
                        themeViewModel.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              AppStrings.settings,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ).tr(),
            const SizedBox(
              height: 20,
            ),
            CustomListTile(
              iconType: Icons.language_rounded,
              title: AppStrings.language.tr(),
              iconColor: Colors.orange,
              circleColor: Colors.orange.shade50,
              subtitle: (Provider.of<LanguageData>(context).languageType ==
                      Language.english)
                  ? 'English'
                  : '中文',
              isSwitch: false,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const LanguageScreen()));
              },
              secondaryContainerColor: themeViewModel.isDarkMode
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade200,
              secondaryIconColor:
                  themeViewModel.isDarkMode ? Colors.white : Colors.black,
            ),
            const SizedBox(
              height: 20,
            ),
            CustomListTile(
              iconType: Icons.dark_mode_rounded,
              iconColor: Colors.purple,
              circleColor: Colors.purple.shade50,
              title: AppStrings.darkMode.tr(),
              subtitle: themeViewModel.isDarkMode
                  ? AppStrings.on.tr()
                  : AppStrings.off.tr(),
              isSwitch: true,
              switchValue: themeViewModel.isDarkMode,
              onSwitch: (value) {
                themeViewModel.toggleTheme(value);
              },
              secondaryContainerColor: themeViewModel.isDarkMode
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade200,
              secondaryIconColor:
                  themeViewModel.isDarkMode ? Colors.white : Colors.black,
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              AppStrings.moreInfo,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ).tr(),
            const SizedBox(
              height: 10,
            ),
            Transform.translate(
              offset: const Offset(-19, 0),
              child: AboutListTile(
                applicationVersion: '1.0',
                applicationName: 'Pawsome',
                applicationIcon: const FlutterLogo(),
                aboutBoxChildren: [
                  const Text(AppStrings.contactMeForAdditionalHelp).tr(),
                  const SizedBox(
                    height: 10,
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'ssgray.developer@gmail.com',
                          style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => launchEmail(),
                          // recognizer:
                        )
                      ],
                    ),
                  ),
                ],
                icon: const Icon(
                  Icons.info_rounded,
                  size: 56,
                ),
              ),
            ),
            // CustomListTile(
            //   iconType: Icons.info_rounded,
            //   iconColor: Theme.of(context).primaryColor,
            //   circleColor: Colors.white,
            //   title: AppStrings.moreInfo.tr(),
            //   isSwitch: false,
            //   secondaryContainerColor: themeViewModel.isDarkMode
            //       ? Theme.of(context).primaryColor
            //       : Colors.grey.shade200,
            //   secondaryIconColor:
            //       themeViewModel.isDarkMode ? Colors.white : Colors.black,
            //   onTap: showAboutDialog(context: context),
            // ),
          ],
        ),
      ),
    );
  }
}
