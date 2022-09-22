import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:pawsome/model/pet_item.dart';
import '../resources/strings_manager.dart';

class PetData extends ChangeNotifier {
  final List<PetItem> _categories = [
    PetItem(
        name: AppStrings.bird,
        value: 'Bird',
        imagePath: 'assets/images/bird.png',
        borderColor: const Color(0XFFB65FCF),
        boxColor: const Color.fromRGBO(225, 226, 236, 1.0)),
    PetItem(
        name: AppStrings.cat,
        value: 'Cat',
        imagePath: 'assets/images/cat.png',
        borderColor: const Color(0XFFAEF359),
        boxColor: const Color.fromRGBO(240, 247, 204, 1.0)),
    PetItem(
        name: AppStrings.dog,
        value: 'Dog',
        imagePath: 'assets/images/dog.png',
        borderColor: const Color.fromRGBO(254, 220, 110, 1.0),
        boxColor: const Color.fromRGBO(246, 239, 212, 1.0)),
    PetItem(
        name: AppStrings.ferret,
        value: 'Ferret',
        imagePath: 'assets/images/ferret.png',
        borderColor: const Color(0xfff4a460),
        boxColor: const Color(0xFFffe4c4)),
    PetItem(
        name: AppStrings.fish,
        value: 'Fish',
        imagePath: 'assets/images/fish.png',
        borderColor: const Color(0XFFfcffa4),
        boxColor: const Color(0xffffffe0)),
    PetItem(
        name: AppStrings.guineaPig,
        value: 'Guinea Pig',
        imagePath: 'assets/images/guineaPig.png',
        borderColor: const Color(0XFFE3242B),
        boxColor: const Color(0xffff9999)),
    PetItem(
        name: AppStrings.horse,
        value: 'Horse',
        imagePath: 'assets/images/horse.png',
        borderColor: const Color(0xfff0e68c),
        boxColor: const Color(0xfff5f5dc)),
    PetItem(
        name: AppStrings.iguana,
        value: 'Iguana',
        imagePath: 'assets/images/iguana.png',
        borderColor: const Color(0xff00ffff),
        boxColor: const Color(0xffe0ffff)),
    PetItem(
        name: AppStrings.mouseRat,
        value: 'Mouse/Rat',
        imagePath: 'assets/images/mouseRat.png',
        borderColor: const Color(0xffacbf60),
        boxColor: const Color(0xffe3f988)),
    PetItem(
        name: AppStrings.otter,
        value: 'Otter',
        imagePath: 'assets/images/otter.png',
        borderColor: const Color(0XFF808080),
        boxColor: const Color.fromRGBO(223, 230, 233, 1.0)),
    PetItem(
        name: AppStrings.rabbit,
        value: 'Rabbit',
        imagePath: 'assets/images/rabbit.png',
        borderColor: const Color(0xffffc0cb),
        boxColor: const Color(0xffffe4e1)),
    PetItem(
        name: AppStrings.tortoise,
        value: 'Tortoise',
        imagePath: 'assets/images/tortoise.png',
        borderColor: const Color(0xffe3dac9),
        boxColor: const Color(0xfffaf0e6)),
  ];

  AnimationController? controller;

  bool selected = false;

  bool shouldShowLoadingCard = false;

  String? selectedPetClass;

  int radius = 5;

  int get itemCount {
    return _categories.length;
  }

  set setShouldLoadingCard(bool value) {
    shouldShowLoadingCard = value;
    notifyListeners();
  }

  set setRadius(int value) {
    radius = value;
    notifyListeners();
  }

  UnmodifiableListView<PetItem> get items {
    return UnmodifiableListView(_categories);
  }

  void updateItem(PetItem? item) {
    for (final category in _categories) {
      category.isSelected = false;
    }
    if (item != null) {
      item.toggleBorderColor();
      selected = true;
      selectedPetClass = item.name;
    } else {
      selected = false;
      selectedPetClass = null;
    }
    notifyListeners();
  }
}
