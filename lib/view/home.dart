import 'package:flutter/material.dart' hide MenuItem;
import 'package:flutter_zoom_drawer/config.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pawsome/configuration/configuration.dart';
import 'package:pawsome/view/adoption.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:pawsome/view/pet_gallery.dart';
import 'package:pawsome/view/pet_map.dart';
import 'package:pawsome/view/settings.dart';
import '../model/menu_item.dart';
import 'drawer.dart';
import 'messages.dart';
import 'my_pets.dart';

class HomeScreen extends StatefulWidget {
  static const String id = '/home';
  final PackageInfo packageInfo;

  const HomeScreen({Key? key, required this.packageInfo}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MenuItem currentItem = MenuItems.adoption;

  @override
  void initState() {
    super.initState();
    // addData();
  }

  // void addData() async {
  //   DrawerViewModel drawerViewModel =
  //       Provider.of<DrawerViewModel>(context, listen: false);
  //   await drawerViewModel.refreshUser();
  // }

  @override
  Widget build(BuildContext context) => ZoomDrawer(
        style: DrawerStyle.defaultStyle,
        mainScreenTapClose: true,
        menuScreenWidth: double.infinity,
        moveMenuScreen: false,
        disableDragGesture: true,
        // showShadow: true,
        menuScreen: Builder(
          builder: (BuildContext context) => DrawerScreen(
            currentItem: currentItem,
            onSelectedItem: (item) {
              setState(() => currentItem = item);
              ZoomDrawer.of(context)!.close();
            },
            packageInfo: widget.packageInfo,
          ),
        ),
        mainScreen: getScreen(),
      );

  Widget getScreen() {
    switch (currentItem) {
      case MenuItems.adoption:
        return const AdoptionScreen();
      // case MenuItems.petStore:
      //   return PetStoreScreen();
      // case MenuItems.veterinaryClinic:
      //   return VeterinaryClinicScreen();
      case MenuItems.myPets:
        return const MyPetsScreen();
      case MenuItems.petGallery:
        return const PetGallery();
      case MenuItems.petMap:
        Geolocator.requestPermission();
        return const PetMapScreen();
      case MenuItems.messages:
        return const MessagesScreen();
      case MenuItems.settings:
        return const SettingsScreen();
      default:
        return Container();
    }
  }
}
