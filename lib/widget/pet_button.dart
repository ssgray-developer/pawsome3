import 'package:flutter/material.dart';

class PetButton extends StatelessWidget {
  final Color boxColor;
  final Color borderColor;
  final String imagePath;
  final String title;
  final VoidCallback onPressed;

  const PetButton(
      {Key? key,
      required this.boxColor,
      required this.borderColor,
      required this.imagePath,
      required this.title,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        constraints: const BoxConstraints(
          minWidth: 90,
        ),
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: borderColor, width: 2.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Image(
                image: AssetImage(imagePath),
                height: 40,
                width: 40,
              ),
            ),
            const SizedBox(
              width: 5.0,
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
