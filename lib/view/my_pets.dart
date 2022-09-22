import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:pawsome/viewmodel/my_pets_viewmodel.dart';
import 'package:pawsome/widget/missing_pet_list.dart';
import 'package:pawsome/widget/registered_pet_list.dart';
import 'package:provider/provider.dart';
import '../resources/strings_manager.dart';

class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({Key? key}) : super(key: key);

  @override
  State<MyPetsScreen> createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  @override
  Widget build(BuildContext context) {
    MyPetsViewModel _myPets = Provider.of<MyPetsViewModel>(context);
    return AbsorbPointer(
      absorbing: _myPets.getIsLoading,
      child: DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.menu,
              ),
              onPressed: () => ZoomDrawer.of(context)!.toggle(),
            ),
            title: const Text(
              AppStrings.myPets,
            ).tr(),
            bottom: TabBar(
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 5,
              indicatorColor: Colors.purple[300],
              tabs: [
                Tab(text: '\t\t\t\t\t${AppStrings.adoption.tr()}\t\t\t\t\t'),
                Tab(text: '\t\t\t\t\t${AppStrings.missing.tr()}\t\t\t\t\t'),
              ],
            ),
            actions: [
              _myPets.getIsLoading
                  ? const Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: SpinKitCircle(
                        color: Colors.white,
                        size: 24,
                      ),
                    )
                  : Container()
            ],
          ),
          body: const TabBarView(
            children: [
              RegisteredPetList(),
              MissingPetList(),
            ],
          ),
        ),
      ),
    );
  }
}
