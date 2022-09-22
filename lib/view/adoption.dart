import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:pawsome/model/language_model.dart';
import 'package:pawsome/model/location.dart';
import 'package:pawsome/resources/strings_manager.dart';
import 'package:pawsome/view/add_pet.dart';
import 'package:pawsome/viewmodel/language_data.dart';
import 'package:pawsome/viewmodel/pet_data.dart';
import 'package:pawsome/widget/adoption_card.dart';
import 'package:pawsome/widget/pet_list.dart';
import 'package:provider/provider.dart';
import '../widget/custom_app_bar.dart';

class AdoptionScreen extends StatefulWidget {
  const AdoptionScreen({Key? key}) : super(key: key);

  @override
  State<AdoptionScreen> createState() => _AdoptionScreenState();
}

class _AdoptionScreenState extends State<AdoptionScreen>
    with SingleTickerProviderStateMixin {
  final ScrollPhysics _physics = const BouncingScrollPhysics();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Geoflutterfire _geo = Geoflutterfire();

  var _collectionReference;

  List<DocumentSnapshot>? adoptionCardList;

  late Stream<List<DocumentSnapshot<Map<String, dynamic>>>> _stream;
  late GeoFirePoint _center;
  late AnimationController _controller;
  late ScrollController _scrollController;

  String? selectedValue;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // _controller = AnimationController(
    //     vsync: this, duration: const Duration(milliseconds: 500));
    _scrollController = ScrollController();
    // _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    // _controller.dispose();
    _scrollController.dispose();
    // _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  Future<void> _refresh() async {
    LocationModel.origin = await LocationModel.determinePosition();
    // _scrollController.addListener(_scrollListener);
    setState(() {});
  }

  void sortAdoptionList() {
    adoptionCardList!.sort((a, b) {
      return LocationModel.getDistanceBetween(
              (a['location']['geopoint'] as GeoPoint).latitude,
              (a['location']['geopoint'] as GeoPoint).longitude)
          .compareTo(LocationModel.getDistanceBetween(
              (b['location']['geopoint'] as GeoPoint).latitude,
              (b['location']['geopoint'] as GeoPoint).longitude));
    });
  }

  // void _scrollListener() {
  //   if (adoptionCardList != null) {
  //     if (adoptionCardList!.length ==
  //         Provider.of<PetData>(context, listen: false).radius) {
  //       if (_scrollController.position.pixels >
  //           _scrollController.position.maxScrollExtent - 100) {
  //         _scrollController.removeListener(_scrollListener);
  //         // Provider.of<PetData>(context, listen: false).setShouldLoadingCard =
  //         //     true;
  //       }
  //     }
  //   }
  // }

  Future<void> _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPetScreen()),
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

  @override
  Widget build(BuildContext context) {
    final PetData petData = Provider.of<PetData>(context);
    final LanguageData languageData = Provider.of<LanguageData>(context);
    _collectionReference = _firestore
        .collection('registeredPets')
        .where('petClass', isEqualTo: petData.selectedPetClass);
    _center = _geo.point(
        latitude: LocationModel.origin!.latitude,
        longitude: LocationModel.origin!.longitude);
    _stream = _geo.collection(collectionRef: _collectionReference).within(
        center: _center,
        radius: petData.radius.toDouble(),
        field: 'location',
        strictMode: true);

    if (petData.controller == null) {
      petData.controller = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 500));
      // petData.controller = _controller;
    } else {
      _controller = petData.controller!;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      key: _scaffoldKey,
      appBar: CustomAppBar(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.menu,
            ),
            onPressed: () => ZoomDrawer.of(context)!.toggle(),
          ),
          title: Text(
            AppStrings.adoption.tr(),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: DropdownButtonHideUnderline(
                child: DropdownButton2(
                  isExpanded: true,
                  hint: Center(
                    child: Text(
                      '${petData.radius} ' + AppStrings.km.tr(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              (languageData.languageType == Language.english)
                                  ? 14
                                  : 12),
                    ),
                  ),
                  items: distanceItem
                      .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  value: selectedValue,
                  onChanged: (value) {
                    if (value != null) {
                      petData.setRadius = int.parse(value as String);
                    }
                  },
                  icon: const Icon(
                    Icons.arrow_forward_ios_outlined,
                  ),
                  iconSize: 14,
                  iconEnabledColor: Colors.yellow,
                  iconDisabledColor: Colors.grey,
                  buttonHeight: 50,
                  buttonWidth: 80,
                  buttonPadding: const EdgeInsets.only(left: 5, right: 5),
                  buttonDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.black26,
                    ),
                    color: Theme.of(context).primaryColor,
                  ),
                  buttonElevation: 2,
                  itemHeight: 40,
                  itemPadding: const EdgeInsets.only(left: 14, right: 14),
                  dropdownMaxHeight: 200,
                  dropdownWidth: 120,
                  dropdownPadding: null,
                  dropdownDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Theme.of(context).primaryColor,
                  ),
                  dropdownElevation: 8,
                  scrollbarRadius: const Radius.circular(40),
                  scrollbarThickness: 6,
                  scrollbarAlwaysShow: true,
                  offset: const Offset(-20, 0),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                _navigateAndDisplaySelection(context);
                // Navigator.of(context).push(MaterialPageRoute(
                //     builder: (context) => const AddPetScreen()));
              },
              icon: const Icon(
                Icons.pets_rounded,
                // color: Colors.black,
              ),
            )
          ],
        ),
        onTap: () {
          if (adoptionCardList != null) {
            _scrollController.animateTo(0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn);
          }
        },
      ),
      body: RefreshIndicator(
        color: Theme.of(context).primaryColor,
        edgeOffset: 90,
        onRefresh: _refresh,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: _physics,
          child: Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  height: 60,
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: petData.selected ? 50 : 0,
                        child: GestureDetector(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: AnimatedIcon(
                              color: petData.selected
                                  ? Colors.red
                                  : Colors.transparent,
                              icon: AnimatedIcons.menu_close,
                              progress: petData.controller ?? _controller,
                            ),
                          ),
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            petData.controller!.reverse();
                            petData.updateItem(null);
                          },
                        ),
                      ),
                      Flexible(
                        child: PetList(
                          triggerAnimation: () {
                            // petData.setAnimatedIconColor = Colors.red;
                            petData.controller!.forward();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // FirestoreListView(
                //   query: queryPost,
                //   itemBuilder: (context, snapshot) {
                //     final post = snapshot.data();
                //     if (snapshot.)
                //   },
                // ),
                StreamBuilder(
                  stream: _stream,
                  builder: (context,
                      AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 10),
                          child: Container(
                              padding: const EdgeInsets.all(10.0),
                              height: 120.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: Theme.of(context).colorScheme.background,
                              ),
                              child: Center(
                                child: SpinKitThreeBounce(
                                  color: Theme.of(context).primaryColor,
                                ),
                              )),
                        ),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.active) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.isNotEmpty) {
                          adoptionCardList = snapshot.data!;
                          sortAdoptionList();
                          // for (DocumentSnapshot document in adoptionCardList!) {
                          //   print(document.data());
                          // }
                          return ListView.builder(
                            padding: const EdgeInsets.all(0),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.length,
                            scrollDirection: Axis.vertical,
                            cacheExtent: 9999,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return AdoptionCard(
                                snap: adoptionCardList![index].data()
                                    as Map<String, dynamic>,
                                index: index,
                              );
                            },
                          );
                        } else {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height - 140,
                            child: Center(
                              child: const Text(AppStrings.noPetsNearby).tr(),
                            ),
                          );
                        }
                      }
                    }
                    return Container();
                  },
                ),
                petData.shouldShowLoadingCard
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 10),
                        child: petData.shouldShowLoadingCard
                            ? Container(
                                padding: const EdgeInsets.all(10.0),
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color:
                                      Theme.of(context).colorScheme.background,
                                ),
                                child: Center(
                                  child: SpinKitThreeBounce(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ))
                            : Container(),
                      )
                    : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
