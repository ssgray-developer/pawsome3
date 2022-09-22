// To parse this JSON data, do
//
//     final petInfo = petInfoFromJson(jsonString);

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

MissingPet missingPetFromJson(String str) =>
    MissingPet.fromJson(json.decode(str));

String missingPetToJson(MissingPet data) => json.encode(data.toJson());

class MissingPet {
  final String postId;
  final String uid;
  final String photoUrl;
  final String gender;
  final String name;
  final String petClass;
  final String petSpecies;
  final String description;
  final Map<String, dynamic> location;
  final FieldValue date;
  final String owner;
  final String ownerUid;
  final String ownerEmail;
  final String ownerPhotoUrl;

  MissingPet({
    required this.postId,
    required this.uid,
    required this.photoUrl,
    required this.gender,
    required this.name,
    required this.petClass,
    required this.petSpecies,
    required this.description,
    required this.location,
    required this.date,
    required this.owner,
    required this.ownerUid,
    required this.ownerEmail,
    required this.ownerPhotoUrl,
  });

  factory MissingPet.fromJson(Map<String, dynamic> json) => MissingPet(
        postId: json["postId"],
        uid: json["uid"],
        photoUrl: json["photoUrl"],
        gender: json["gender"],
        name: json["name"],
        petClass: json["petClass"],
        petSpecies: json["petSpecies"],
        description: json["description"],
        location: json["location"],
        date: json["date"] as FieldValue,
        owner: json["owner"],
        ownerUid: json["ownerUid"],
        ownerEmail: json["ownerEmail"],
        ownerPhotoUrl: json["ownerPhotoUrl"],
      );

  Map<String, dynamic> toJson() => {
        "postId": postId,
        "uid": uid,
        "photoUrl": photoUrl,
        "gender": gender,
        "name": name,
        "petClass": petClass,
        "petSpecies": petSpecies,
        "description": description,
        "location": location,
        "date": date,
        "owner": owner,
        "ownerUid": ownerUid,
        "ownerEmail": ownerEmail,
        "ownerPhotoUrl": ownerPhotoUrl,
      };
}
