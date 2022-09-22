import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pawsome/model/firebase_methods/auth_methods.dart';

import '../model/user.dart';

class UserViewModel extends ChangeNotifier {
  User? _user;
  Uint8List? image;

  final AuthMethods _authMethods = AuthMethods();
  String? name;

  User get getUser => _user!;

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails(null);
    _user = user;
    // notifyListeners();
  }

  void refreshPicture(Uint8List imageData) {
    image = imageData;
    notifyListeners();
  }

  void refreshName(String newName) {
    name = newName;
    notifyListeners();
  }
}
