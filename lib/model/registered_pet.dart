// To parse this JSON data, do
//
//     final petInfo = petInfoFromJson(jsonString);

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

RegisteredPet registeredPetFromJson(String str) =>
    RegisteredPet.fromJson(json.decode(str));

String registeredPetToJson(RegisteredPet data) => json.encode(data.toJson());

class RegisteredPet {
  final String postId;
  final String uid;
  final String photoUrl;
  final String gender;
  final String name;
  final String age;
  final String petClass;
  final String petSpecies;
  final String petPrice;
  final String description;
  final Map<String, dynamic> location;
  final FieldValue date;
  final String owner;
  final String ownerUid;
  final String ownerEmail;
  final String ownerPhotoUrl;
  final List likes;

  RegisteredPet({
    required this.postId,
    required this.uid,
    required this.photoUrl,
    required this.gender,
    required this.name,
    required this.age,
    required this.petClass,
    required this.petSpecies,
    required this.petPrice,
    required this.description,
    required this.location,
    required this.date,
    required this.owner,
    required this.ownerUid,
    required this.ownerEmail,
    required this.ownerPhotoUrl,
    required this.likes,
  });

  factory RegisteredPet.fromJson(Map<String, dynamic> json) => RegisteredPet(
        postId: json["postId"],
        uid: json["uid"],
        photoUrl: json["photoUrl"],
        gender: json["gender"],
        name: json["name"],
        age: json["age"],
        petClass: json["petClass"],
        petSpecies: json["petSpecies"],
        petPrice: json["petPrice"],
        description: json["description"],
        location: json["location"],
        date: json["date"],
        owner: json["owner"],
        ownerUid: json["ownerUid"],
        ownerEmail: json["ownerEmail"],
        ownerPhotoUrl: json["ownerPhotoUrl"],
        likes: json["likes"],
      );

  Map<String, dynamic> toJson() => {
        "postId": postId,
        "uid": uid,
        "photoUrl": photoUrl,
        "gender": gender,
        "name": name,
        "age": age,
        "petClass": petClass,
        "petSpecies": petSpecies,
        "petPrice": petPrice,
        "description": description,
        "location": location,
        "date": date,
        "owner": owner,
        "ownerUid": ownerUid,
        "ownerEmail": ownerEmail,
        "ownerPhotoUrl": ownerPhotoUrl,
        "likes": likes,
      };
}
