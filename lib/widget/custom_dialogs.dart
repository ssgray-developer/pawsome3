import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<dynamic> showAlertDialog({
  required BuildContext context,
  required String title,
  required String cancelActionText,
  required String defaultActionText,
  required List<Widget> children,
  required VoidCallback onPressed,
}) async {
  if (!Platform.isIOS) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          children: children,
        ),
        actions: [
          TextButton(
            child: Text(cancelActionText),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(child: Text(defaultActionText), onPressed: onPressed),
        ],
      ),
    );
  }

  // todo : showDialog for ios
  return showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title),
      content: Column(
        children: children,
      ),
      actions: [
        CupertinoDialogAction(
          child: Text(cancelActionText),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        CupertinoDialogAction(
            child: Text(defaultActionText), onPressed: onPressed),
      ],
    ),
  );
}
