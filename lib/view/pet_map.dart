import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pawsome/view/report_pet.dart';
import 'package:pawsome/widget/animated_markers_map.dart';

import '../model/location.dart';
import '../resources/strings_manager.dart';

class PetMapScreen extends StatefulWidget {
  const PetMapScreen({Key? key}) : super(key: key);

  @override
  State<PetMapScreen> createState() => _PetMapScreenState();
}

class _PetMapScreenState extends State<PetMapScreen> {
  Position updatedLocation = LocationModel.origin!;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    syncLocation();
  }

  Future<void> _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportPetScreen()),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if (result != null) {
      // ScaffoldMessenger.of(context)
      _scaffoldKey.currentState!
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(
            '$result',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          animation: null,
        ));
    }
  }

  Future<void> syncLocation() async {
    updatedLocation = await LocationModel.determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.menu,
            ),
            onPressed: () => ZoomDrawer.of(context)!.toggle(),
          ),
          title: const Text(
            AppStrings.petMap,
          ).tr(),
          actions: [
            TextButton(
                onPressed: () {
                  _navigateAndDisplaySelection(context);
                },
                child: SizedBox(
                  width: 100,
                  child: const Text(
                    AppStrings.reportMissingPet,
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ).tr(),
                ))
          ],
        ),
        body: const AnimatedMarkersMap());
  }
}
