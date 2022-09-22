import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final Function(bool)? onSwitch;
  final VoidCallback? onTap;
  final IconData iconType;
  final Color iconColor;
  final Color secondaryIconColor;
  final Color secondaryContainerColor;
  final Color circleColor;
  final String title;
  final String? subtitle;
  final bool isSwitch;
  final bool? switchValue;
  const CustomListTile({
    Key? key,
    this.onTap,
    required this.iconType,
    required this.iconColor,
    required this.circleColor,
    required this.title,
    this.subtitle,
    required this.isSwitch,
    this.onSwitch,
    this.switchValue,
    required this.secondaryIconColor,
    required this.secondaryContainerColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: circleColor,
          child: Icon(
            iconType,
            color: iconColor,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Expanded(child: Container()),
        Text(
          subtitle ?? '',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        isSwitch
            ? const SizedBox(
                width: 1,
              )
            : const SizedBox(
                width: 20,
              ),
        isSwitch
            ? Transform.translate(
                offset: const Offset(10, 0),
                child: Transform.scale(
                  scale: 0.8,
                  child: CupertinoSwitch(
                    onChanged: onSwitch,
                    value: switchValue!,
                    // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              )
            : GestureDetector(
                onTap: onTap,
                child: Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: secondaryContainerColor,
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: secondaryIconColor,
                  ),
                ),
              ),
      ],
    );
  }
}
