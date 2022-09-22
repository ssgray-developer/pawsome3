import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pawsome/model/language_model.dart';
import 'package:pawsome/resources/language_manager.dart';
import 'package:pawsome/resources/theme_manager.dart';
import 'package:pawsome/view/loading.dart';
import 'package:pawsome/view/login.dart';
import 'package:pawsome/viewmodel/language_data.dart';
import 'package:pawsome/viewmodel/missing_pet_data.dart';
import 'package:pawsome/viewmodel/my_pets_viewmodel.dart';
import 'package:pawsome/viewmodel/theme_viewmodel.dart';
import 'package:pawsome/viewmodel/user_viewmodel.dart';
import 'package:pawsome/viewmodel/login_viewmodel.dart';
import 'package:pawsome/viewmodel/pet_data.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Keep splash screen until initialization has completed!
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  // ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => LanguageData(),
        ),
        ChangeNotifierProvider(
          create: (_) => MyPetsViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => PetData(),
        ),
        ChangeNotifierProvider(
          create: (_) => MissingPetData(),
        ),
      ],
      child: EasyLocalization(
        path: ASSETS_PATH_LOCALISATIONS,
        supportedLocales: const [ENGLISH_LOCAL, CHINESE_LOCAL],
        fallbackLocale: ENGLISH_LOCAL,
        child: Phoenix(
          child: MyApp(
            packageInfo: packageInfo,
          ),
        ),
      ),
    ),
  );

  FlutterNativeSplash.remove();
}

class MyApp extends StatefulWidget {
  final PackageInfo packageInfo;
  const MyApp({Key? key, required this.packageInfo}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Stream _fireStream;
  ThemeViewModel themeViewModel = ThemeViewModel();
  LanguageData languageData = LanguageData();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fireStream = FirebaseAuth.instance.authStateChanges();
    getAppPreferences();
  }

  void getAppPreferences() async {
    final bool value = await themeViewModel.themePreference.getTheme();
    final String language = await languageData.languagePreference.getLanguage();

    Provider.of<ThemeViewModel>(context, listen: false).toggleTheme(value);

    // Provider.of<ThemeViewModel>(context, listen: false).themeMode =
    //     value ? ThemeMode.dark : ThemeMode.light;
    Provider.of<LanguageData>(context, listen: false).languageType =
        language == 'English' ? Language.english : Language.chinese;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeViewModel = Provider.of<ThemeViewModel>(context);
    final languageData = Provider.of<LanguageData>(context);
    // SystemChrome.setSystemUIOverlayStyle(
    //   SystemUiOverlayStyle(statusBarColor: Colors.white),
    // );
    return MaterialApp(
      themeMode: themeViewModel.themeMode,
      darkTheme: getDarkTheme(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: 'Pawsome',
      theme: getLightTheme(),
      home: StreamBuilder(
        stream: _fireStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              // User is logged in
              // print('User is logged in');
              return LoadingScreen(
                packageInfo: widget.packageInfo,
              );
            } else if (snapshot.hasError) {
              // print('main screen has error');
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                child: Center(
                  child: SpinKitCircle(color: Theme.of(context).primaryColor),
                ),
              );
            }
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            // print('connection is waiting');
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              child: Center(
                child: SpinKitCircle(color: Theme.of(context).primaryColor),
              ),
            );
          }
          themeViewModel.themeMode = ThemeMode.light;
          languageData.languageType = Language.english;
          return LoginScreen(
            packageInfo: widget.packageInfo,
          );
        },
      ),
      // routes: {
      //   LoadingScreen.id: (context) => const LoadingScreen(),
      //   LoginScreen.id: (context) => const LoginScreen(),
      //   RegisterScreen.id: (context) => const RegisterScreen(),
      //   HomeScreen.id: (context) => const HomeScreen(),
      // },
    );
  }
}
