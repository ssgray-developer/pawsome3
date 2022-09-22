import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

import '../resources/strings_manager.dart';

class PetGallery extends StatefulWidget {
  const PetGallery({Key? key}) : super(key: key);

  @override
  State<PetGallery> createState() => _PetGalleryState();
}

class _PetGalleryState extends State<PetGallery> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => ZoomDrawer.of(context)!.toggle(),
          icon: const Icon(Icons.menu),
        ),
        title: const Text(AppStrings.petGallery).tr(),
      ),
      body: Center(
        child: const Text(AppStrings.contentAvailableSoon).tr(),
      ),
    );
  }
}
