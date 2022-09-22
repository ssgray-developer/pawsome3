import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pawsome/widget/pet_button.dart';
import 'package:provider/provider.dart';
import '../viewmodel/pet_data.dart';

class PetList extends StatelessWidget {
  final VoidCallback triggerAnimation;
  const PetList({Key? key, required this.triggerAnimation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PetData>(builder: (context, petData, child) {
      return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: petData.itemCount,
          physics: const ClampingScrollPhysics(),
          itemBuilder: (context, index) {
            final pet = petData.items[index];
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 6, 15, 6),
              child: PetButton(
                boxColor: pet.boxColor,
                borderColor: pet.isSelected ? pet.borderColor : pet.boxColor,
                imagePath: pet.imagePath,
                title: pet.name.tr(),
                onPressed: () {
                  petData.updateItem(pet);
                  triggerAnimation();
                },
              ),
            );
          });
    });
  }
}
