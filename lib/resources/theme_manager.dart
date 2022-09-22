import 'package:flutter/material.dart';
import 'package:pawsome/resources/color_manager.dart';
import 'package:pawsome/resources/font_manager.dart';
import 'package:pawsome/resources/styles_manager.dart';
import 'package:pawsome/resources/values_manager.dart';

ThemeData getLightTheme() {
  return ThemeData(
    primaryColor: ColorManager.primary,
    secondaryHeaderColor: ColorManager.secondary,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      secondaryContainer: Color.fromRGBO(242, 242, 242, 1),
      inversePrimary: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontSize: FontSize.s18,
      ),
      backgroundColor: ColorManager.primary,
      elevation: 0,
    ),
    radioTheme: RadioThemeData(
        fillColor:
            MaterialStateColor.resolveWith((states) => ColorManager.primary)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle:
            getRegularStyle(color: ColorManager.white, fontSize: AppSize.s16),
        primary: ColorManager.primary,
        elevation: AppSize.s0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s28),
        ),
      ),
    ),
  );
}

ThemeData getDarkTheme() {
  return ThemeData(
    primaryColor: ColorManager.primary,
    secondaryHeaderColor: ColorManager.secondary,
    scaffoldBackgroundColor: Colors.grey.shade900,
    colorScheme: ColorScheme.dark(
      secondaryContainer: Colors.grey[900],
    ),
    appBarTheme: AppBarTheme(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontSize: FontSize.s18,
      ),
      backgroundColor: ColorManager.primary,
      elevation: 0,
    ),
    radioTheme: RadioThemeData(
        fillColor:
            MaterialStateColor.resolveWith((states) => ColorManager.primary)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle:
            getRegularStyle(color: ColorManager.white, fontSize: AppSize.s16),
        primary: ColorManager.primary,
        elevation: AppSize.s0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s28),
        ),
      ),
    ),
    // textSelectionTheme: TextSelectionThemeData(
    //   selectionColor: ColorManager.primary,
    // ),
  );
}
