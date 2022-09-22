import 'package:flutter/material.dart';
import '../model/location.dart';
import 'package:latlong2/latlong.dart';

class MissingPetData extends ChangeNotifier {
  LatLng location =
      LatLng(LocationModel.origin!.latitude, LocationModel.origin!.longitude);

  double zoomValue = 14;

  set setLocation(LatLng newLocation) {
    location = newLocation;
    notifyListeners();
  }

  set setZoomValue(double newValue) {
    zoomValue = newValue;
    notifyListeners();
  }
}
