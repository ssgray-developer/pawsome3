import 'package:flutter/material.dart';

class PetItem {
  final String name;
  final String value;
  final String imagePath;
  Color borderColor;
  bool isSelected;
  final Color boxColor;

  PetItem(
      {required this.name,
      required this.value,
      required this.imagePath,
      required this.borderColor,
      this.isSelected = false,
      required this.boxColor});

  void toggleBorderColor() {
    isSelected = !isSelected;
  }
}
