import 'package:flutter/material.dart';

class MyPetsViewModel extends ChangeNotifier {
  bool _isLoading = false;

  set setIsLoading(bool state) {
    _isLoading = state;
    notifyListeners();
  }

  bool get getIsLoading {
    return _isLoading;
  }
}
