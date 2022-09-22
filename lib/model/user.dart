import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String photoUrl;
  final List chatId;
  final String username;
  final List petList;
  final List missingPetList;

  const User(
      {required this.email,
      required this.uid,
      this.photoUrl = '',
      required this.chatId,
      required this.username,
      required this.petList,
      required this.missingPetList});

  Map<String, dynamic> toJson() => {
        'email': email,
        'uid': uid,
        'photoUrl': photoUrl,
        'username': username,
        'chatId': chatId,
        'petList': petList,
        'missingPetList': missingPetList
      };

  static User fromSnapshot(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
        username: snapshot['username'],
        email: snapshot['email'],
        uid: snapshot['uid'],
        photoUrl: snapshot['photoUrl'],
        chatId: snapshot['chatId'],
        petList: snapshot['petList'],
        missingPetList: snapshot['missingPetList']);
  }
}
