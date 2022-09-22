// To parse this JSON data, do
//
//     final message = messageFromMap(jsonString);

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

Message messageFromMap(String str) => Message.fromMap(json.decode(str));

String messageToMap(Message data) => json.encode(data.toMap());

class Message {
  Message({
    required this.sender,
    required this.text,
    required this.type,
    required this.timeSent,
    required this.isSeen,
  });

  final String sender;
  final String type;
  final String text;
  final DateTime timeSent;
  final bool isSeen;

  factory Message.fromMap(Map<String, dynamic> json) => Message(
        sender: json["sender"],
        text: json["text"],
        type: json["type"],
        timeSent: (json["datetime"] as Timestamp).toDate(),
        isSeen: json["seen"],
      );

  Map<String, dynamic> toMap() => {
        "sender": sender,
        "text": text,
        "type": type,
        "datetime": timeSent,
        "seen": isSeen,
      };
}
