// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:pawsome/model/location.dart';
import 'package:pawsome/model/user.dart';
import 'package:pawsome/view/missing_pet_details.dart';
import 'package:pawsome/viewmodel/theme_viewmodel.dart';
import 'package:provider/provider.dart';
import '../viewmodel/missing_pet_data.dart';
import '../viewmodel/user_viewmodel.dart';

const MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1Ijoic2VhbmdyYXkxMjMiLCJhIjoiY2wzb2xnb3h3MHBnYTNkbTk0ZDR6aW16NiJ9.QhlaKJ2o1BFAiy7T94UeGQ';
const MAPBOX_DARK = 'mapbox/dark-v10';
const MAPBOX_LIGHT = 'mapbox/light-v10';
// const MARKER_COLOR

// final _myLocation = LatLng(LocationModel.origin!.latitude, 110.403854);

class AnimatedMarkersMap extends StatefulWidget {
  const AnimatedMarkersMap({Key? key}) : super(key: key);

  @override
  State<AnimatedMarkersMap> createState() => _AnimatedMarkersMapState();
}

class _AnimatedMarkersMapState extends State<AnimatedMarkersMap>
    with SingleTickerProviderStateMixin {
  late MapController _mapController;
  late AnimationController _animationController;
  // late Stream<LocationData> _positionStream;
  LocationData? _currentLocation;
  late Stream<List<DocumentSnapshot<Map<String, dynamic>>>> _stream;
  late GeoFirePoint _center;
  final Location _location = Location();

  Function(MapPosition, bool)? _onPositionChanged;

  final Geoflutterfire _geo = Geoflutterfire();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Query<Map<String, dynamic>> _collectionReference;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _animationController.repeat(reverse: true);
    _getCurrentLocation();
    // _positionStream = Geolocator.getPositionStream(
    //     locationSettings: const LocationSettings(
    //         accuracy: LocationAccuracy.bestForNavigation));
    // _positionStream = _location.onLocationChanged;
    _collectionReference = _firestore.collection('missingPets');
    _center = _geo.point(
        latitude: LocationModel.origin!.latitude,
        longitude: LocationModel.origin!.longitude);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _animationController.dispose();
    super.dispose();
  }

  void _getCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentLocation = await _location.getLocation();

    _location.onLocationChanged.listen((newLoc) {
      _currentLocation = newLoc;
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final MissingPetData missingPetData = Provider.of<MissingPetData>(context);
    User _user = Provider.of<UserViewModel>(context, listen: false).getUser;
    ThemeViewModel themeViewModel = Provider.of<ThemeViewModel>(context);

    _stream = _geo.collection(collectionRef: _collectionReference).within(
        center: _geo.point(
            latitude: missingPetData.location.latitude,
            longitude: missingPetData.location.longitude),
        radius: 20,
        field: 'location',
        strictMode: true);

    return _currentLocation == null
        ? Stack(
            children: [
              Center(
                child: SpinKitCircle(color: Theme.of(context).primaryColor),
              ),
              Container(
                margin: const EdgeInsets.only(top: 200),
                child: const Center(
                  child: Text('Location access is required for this feature.'),
                ),
              ),
            ],
          )
        : Stack(
            children: [
              StreamBuilder(
                  stream: _stream,
                  builder: (context,
                      AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                    List<Marker> _listMarkers = [];
                    if (snapshot.hasData) {
                      if (snapshot.data!.isNotEmpty) {
                        for (var element in snapshot.data!) {
                          _listMarkers.add(
                            Marker(
                              height: 7 * exp(missingPetData.zoomValue / 5),
                              width: 7 * exp(missingPetData.zoomValue / 5),
                              point: LatLng(
                                  ((element.data()! as Map<String, dynamic>)[
                                          'location']['geopoint'] as GeoPoint)
                                      .latitude,
                                  ((element.data()! as Map<String, dynamic>)[
                                          'location']['geopoint'] as GeoPoint)
                                      .longitude),
                              builder: (_) {
                                return _MyLocationMarker(
                                    _animationController,
                                    element.data() as Map<String, dynamic>,
                                    missingPetData.zoomValue,
                                    _user);
                              },
                            ),
                          );
                        }
                      }
                    }
                    return FlutterMap(
                      mapController: _mapController,
                      // children: [
                      //   LocationMarkerLayerWidget(),
                      // ],
                      options: MapOptions(
                        minZoom: 13,
                        maxZoom: 18,
                        zoom: missingPetData.zoomValue,
                        center: LatLng(_currentLocation!.latitude!,
                            _currentLocation!.longitude!),
                        onMapCreated: (c) {
                          _mapController = c;
                          _onPositionChanged = (_, value) {
                            missingPetData.setZoomValue = _mapController.zoom;
                          };
                        },
                        onPositionChanged: _onPositionChanged,
                      ),
                      nonRotatedLayers: [
                        TileLayerOptions(
                            urlTemplate:
                                'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                            additionalOptions: {
                              'accessToken': MAPBOX_ACCESS_TOKEN,
                              'id': themeViewModel.isDarkMode
                                  ? MAPBOX_DARK
                                  : MAPBOX_LIGHT
                            }),
                        MarkerLayerOptions(
                          markers: _listMarkers.followedBy([
                            Marker(
                              width: 30,
                              height: 30,
                              builder: (_) {
                                // return _MyLocationMarker(_animationController);
                                return Container(
                                  height: 20.0,
                                  width: 20.0,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                      shape: BoxShape.circle),
                                  child: Icon(
                                    Icons.pets_rounded,
                                    color: Theme.of(context).primaryColor,
                                    size: 18,
                                  ),
                                );
                              },
                              point: LatLng(_currentLocation!.latitude!,
                                  _currentLocation!.longitude!),
                            )
                          ]).toList(),
                        ),
                      ],
                    );
                  }),
              Align(
                alignment: Alignment.bottomRight,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            _mapController.move(
                                LatLng(_currentLocation!.latitude!,
                                    _currentLocation!.longitude!),
                                14);
                          },
                          icon: Icon(
                            Icons.my_location,
                            color: Theme.of(context).primaryColor,
                          ),
                          iconSize: 30,
                        ),
                        IconButton(
                          onPressed: () {
                            missingPetData.setLocation = _mapController.center;
                          },
                          icon: Icon(
                            Icons.search_rounded,
                            color: Theme.of(context).primaryColor,
                          ),
                          iconSize: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
  }
}

class _MyLocationMarker extends AnimatedWidget {
  final Map<String, dynamic> snap;
  final double zoomValue;
  final User _user;
  const _MyLocationMarker(
      Animation<double> animation, this.snap, this.zoomValue, this._user,
      {Key? key})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final value = (listenable as Animation<double>).value;
    final newValue = lerpDouble(0.8, 1, value)!;
    return Center(
      child: Stack(
        children: [
          Center(
            child: Container(
              height: 7 * newValue * exp(zoomValue / 5),
              width: 7 * newValue * exp(zoomValue / 5),
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red, width: 1)),
            ),
          ),
          // Center(
          //   child: Container(
          //     height: 10.0 * zoomValue,
          //     width: 10.0 * zoomValue,
          //     decoration: BoxDecoration(
          //         // color: Theme.of(context).primaryColor,
          //         shape: BoxShape.circle,
          //         border: Border.all(
          //           width: 5,
          //           color: Theme.of(context).scaffoldBackgroundColor,
          //         )),
          //   ),
          // ),
          Center(
            child: GestureDetector(
              child: CircleAvatar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                radius: 25,
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: NetworkImage(snap['photoUrl']),
                ),
              ),
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (builder) {
                      return Container(
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: MissingPetDetails(
                          snap: snap,
                          user: _user,
                        ),
                      );
                    });
              },
            ),
          ),
        ],
      ),
    );
  }
}
