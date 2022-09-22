import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide MenuItem;
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pawsome/model/firebase_methods/auth_methods.dart';
import 'package:pawsome/model/language_model.dart';
import 'package:pawsome/resources/strings_manager.dart';
import 'package:pawsome/utils/utils.dart';
import 'package:pawsome/viewmodel/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:store_redirect/store_redirect.dart';
import '../configuration/configuration.dart';
import '../model/menu_item.dart';
import '../resources/language_manager.dart';
import '../viewmodel/language_data.dart';
import '../viewmodel/theme_viewmodel.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class DrawerScreen extends StatefulWidget {
  final MenuItem currentItem;
  final ValueChanged<MenuItem> onSelectedItem;
  final PackageInfo packageInfo;

  const DrawerScreen(
      {Key? key,
      required this.currentItem,
      required this.onSelectedItem,
      required this.packageInfo})
      : super(key: key);

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  // Uint8List? _image;
  // String username = '';
  late StreamSubscription _subscription;
  late Stream<DocumentSnapshot> _stream;
  late Future<DocumentSnapshot> _future;

  bool _shouldShowAppNotification = true;
  bool _shouldShow = false;

  static final customCacheManager = CacheManager(
    Config(
      'profilePicture',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 1,
    ),
  );

  @override
  void initState() {
    super.initState();
    _subscription =
        Connectivity().onConnectivityChanged.listen(_showConnectivitySnackBar);

    _stream = FirebaseFirestore.instance
        .collection('appInfo')
        .doc('appVersion')
        .snapshots();

    _future = FirebaseFirestore.instance
        .collection('appInfo')
        .doc('appNotification')
        .get();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _showUpdateNotification() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
                title: const Text(AppStrings.updateRequired).tr(),
                content: Text(Platform.isIOS
                        ? AppStrings.updateAppStore
                        : AppStrings.updatePlayStore)
                    .tr(),
                actions: [
                  TextButton(
                      onPressed: navigateToStore,
                      child: const Text(AppStrings.update).tr()),
                ],
              ));
    });
  }

  void _showAppNotification(String content) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
                title: const Text('Welcome to Pawsome!'),
                content: Text(content),
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2.5,
                    height: 50,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: const Text('Close'),
                    ),
                  )
                ],
              ));
    });
  }

  void navigateToStore() {
    StoreRedirect.redirect(
        androidAppId: "com.iyaffle.rangoli", iOSAppId: "585027354");
  }

  void _showConnectivitySnackBar(ConnectivityResult result) {
    final hasInternet = result != ConnectivityResult.none;
    if (!hasInternet) {
      _shouldShow = true;
    }
    final message = hasInternet
        ? AppStrings.hasConnection.tr()
        : AppStrings.noConnection.tr();

    if (_shouldShow) {
      showSnackBar(context, message, defaultColor: hasInternet);
    }
  }

  // ImageProvider _getNetworkImage() {
  // if (Provider.of<UserViewModel>(context).getUser.photoUrl == '') {
  //   return const AssetImage('assets/images/default_picture.png');
  //   return const NetworkImage(
  //       'https://t4.ftcdn.net/jpg/02/15/84/43/360_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg');
  // } else {
  //   checkConnectivity().then((bool value) {
  //     if (value) {
  //       return NetworkImage(
  //           Provider.of<UserViewModel>(context).getUser.photoUrl);
  //     } else {
  //       return const AssetImage('assets/images/default_picture.png');
  //     }
  //   });
  // }
  // }

  ImageProvider _getProfileImage(UserViewModel _user) {
    if (_user.getUser.photoUrl == '') {
      return const AssetImage('assets/images/default_picture.png');
    } else {
      return CachedNetworkImageProvider(
        _user.getUser.photoUrl,
        cacheManager: customCacheManager,
      );
    }
  }

  void signOutUser() async {
    ZoomDrawer.of(context)!.close();
    final themeViewModel = Provider.of<ThemeViewModel>(context, listen: false);
    themeViewModel.toggleTheme(false);
    final languageData = Provider.of<LanguageData>(context, listen: false);
    languageData.changeLocale(
        context, LanguageModel(Language.english, 'English', ENGLISH_LOCAL));
    Phoenix.rebirth(context);
    await AuthMethods.signOutUser();
    // Navigator.pushReplacementNamed(context, LoginScreen.id);
  }

  @override
  Widget build(BuildContext context) {
    UserViewModel _user = Provider.of<UserViewModel>(context);
    ThemeViewModel _themeViewModel = Provider.of<ThemeViewModel>(context);
    return StreamBuilder<DocumentSnapshot>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // print(snapshot.data!.data());
            String latestVersion =
                (snapshot.data!.data() as Map<String, dynamic>)['version'];
            if (widget.packageInfo.version != latestVersion) {
              _showUpdateNotification();
            }
          }
          return FutureBuilder(
            future: _future,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                final String content = snapshot.data['notification'];
                if (content != '' && _shouldShowAppNotification) {
                  _showAppNotification(content);
                  _shouldShowAppNotification = false;
                }
              }
              return Container(
                color: Theme.of(context).primaryColor,
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  // backgroundColor: Theme.of(context).secondaryHeaderColor,
                  body: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: _themeViewModel.isDarkMode
                                ? const AssetImage(
                                    'assets/images/background_dark.jpg')
                                : const AssetImage(
                                    'assets/images/background.jpg'),
                            // colorFilter: ColorFilter.mode(
                            //     Colors.black.withOpacity(0.2), BlendMode.srcATop),
                            fit: BoxFit.cover)),
                    child: SafeArea(
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _user.image != null
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, top: 35.0),
                                  child: Row(
                                    children: [
                                      FullScreenWidget(
                                        child: CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          backgroundImage:
                                              MemoryImage(_user.image!),
                                          radius: 40.0,
                                        ),
                                      ),
                                      Expanded(child: Container()),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, top: 35.0),
                                  child: Row(
                                    children: [
                                      FullScreenWidget(
                                        child: CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          radius: 40.0,
                                          foregroundImage:
                                              _getProfileImage(_user),
                                          backgroundImage: const AssetImage(
                                              'assets/images/default_picture.png'),
                                        ),
                                      ),
                                      Expanded(child: Container()),
                                    ],
                                  ),
                                ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 15.0, top: 20.0),
                            child: Text(
                              _user.name ?? _user.getUser.username,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 24.0,
                                color: _themeViewModel.isDarkMode
                                    ? Colors.grey[600]!
                                    : Colors.black,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Divider(
                            thickness: 1,
                            color: Colors.grey.shade300,
                            indent: 15.0,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Column(
                            children: MenuItems.all
                                .map((e) => ListTile(
                                      selected: widget.currentItem == e,
                                      horizontalTitleGap: 5.0,
                                      iconColor: Colors.black,
                                      onTap: () => widget.onSelectedItem(e),
                                      visualDensity: VisualDensity.compact,
                                      leading: Icon(
                                        e.icon,
                                        color: widget.currentItem == e
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey[600]!,
                                      ),
                                      title: Text(
                                        e.title.tr(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: widget.currentItem == e
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey[600]!,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                          Expanded(child: Container()),
                          ListTile(
                            onTap: signOutUser,
                            horizontalTitleGap: 5.0,
                            leading: Icon(
                              Icons.logout,
                              color: Colors.grey[600]!,
                            ),
                            title: Text(
                              AppStrings.logout.tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600]!,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        });
  }
}
