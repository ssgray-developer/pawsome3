import 'package:flutter/material.dart';

class DateChip extends StatelessWidget {
  final String date;

  const DateChip({
    Key? key,
    required this.date,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 7,
        bottom: 7,
      ),
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 50,
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          color: Theme.of(context).primaryColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            date,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
