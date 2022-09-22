import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pawsome/model/firebase_methods/auth_methods.dart';
import 'package:pawsome/model/firebase_methods/storage_methods.dart';
import 'package:pawsome/model/registered_pet.dart';
import 'package:pawsome/resources/strings_manager.dart';
import 'package:uuid/uuid.dart';

import '../missing_pet.dart';
import '../user.dart';

class FirestoreMethods {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final geo = Geoflutterfire();
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // upload messages
  static void uploadMessage(String text, String senderEmail, String senderUid,
      String recipientUid, String chatId, String type) async {
    await _firestore.collection('users').doc(senderUid).update({
      'chatId': FieldValue.arrayUnion([chatId])
    });

    await _firestore.collection('users').doc(recipientUid).update({
      'chatId': FieldValue.arrayUnion([chatId])
    });

    await _firestore.collection('messages').doc(chatId).set({
      'contacts': [senderUid, recipientUid],
      'lastModified': FieldValue.serverTimestamp(),
      'lastMessage': text,
      'type': type
    });

    await _firestore
        .collection('messages')
        .doc(chatId)
        .collection('chats')
        .add({
      'text': text,
      'sender': senderEmail,
      'datetime': FieldValue.serverTimestamp(),
      'seen': false,
      'type': type
    });
  }

  static Future<String> updateRegisteredPet(User user) async {
    String res = AppStrings.unknownErrorOccurred.tr();
    String petListSuccess = 'fail';
    String petLostSuccess = 'fail';
    if (user.petList.isNotEmpty) {
      for (String pet in user.petList) {
        try {
          await _firestore
              .collection('registeredPets')
              .doc(pet)
              .update({'ownerPhotoUrl': user.photoUrl});
          await _firestore
              .collection('registeredPets')
              .doc(pet)
              .update({'owner': user.username});
          petListSuccess = 'success';
        } catch (e) {
          res = e.toString();
        }
      }
    } else {
      petListSuccess = 'success';
    }

    if (user.missingPetList.isNotEmpty) {
      for (String lostPet in user.missingPetList) {
        try {
          await _firestore
              .collection('missingPets')
              .doc(lostPet)
              .update({'ownerPhotoUrl': user.photoUrl});
          await _firestore
              .collection('missingPets')
              .doc(lostPet)
              .update({'owner': user.username});
          petLostSuccess = 'success';
        } catch (e) {
          res = e.toString();
        }
      }
    } else {
      petLostSuccess = 'success';
    }

    if (petListSuccess == 'success' && petLostSuccess == 'success') {
      return 'success';
    } else {
      return res;
    }
  }

  // upload registered pet
  static Future<String> uploadRegisteredPet(
      Uint8List file,
      String uid,
      String gender,
      String name,
      String age,
      String petClass,
      String petSpecies,
      String petPrice,
      String description,
      String owner,
      String ownerUid,
      String ownerEmail,
      Position currentLocation,
      String ownerPhotoUrl) async {
    try {
      String postId = const Uuid().v1();

      String photoUrl = await StorageMethods.uploadImageToStorage(
          'registeredPets', file, postId, true);

      Position latLon = currentLocation;
      GeoFirePoint myLocation =
          geo.point(latitude: latLon.latitude, longitude: latLon.longitude);

      // testing purposes
      // GeoFirePoint myLocation =
      //     geo.point(latitude: 1.452804, longitude: 110.417855);

      RegisteredPet registeredPet = RegisteredPet(
          postId: postId,
          uid: uid,
          photoUrl: photoUrl,
          gender: gender,
          name: name,
          age: age,
          petClass: petClass,
          petSpecies: petSpecies,
          petPrice: petPrice,
          description: description,
          location: myLocation.data,
          date: FieldValue.serverTimestamp(),
          owner: owner,
          ownerUid: ownerUid,
          ownerEmail: ownerEmail,
          ownerPhotoUrl: ownerPhotoUrl,
          likes: []);

      await _firestore
          .collection('registeredPets')
          .doc(postId)
          .set(registeredPet.toJson());

      await AuthMethods.updateUser('petList', FieldValue.arrayUnion([postId]));

      return ('success');
    } on FirebaseAuthException catch (e) {
      return e.message ?? e.toString();
    }
  }

  // upload missing pet
  static Future<String> uploadMissingPet(
      Uint8List file,
      String uid,
      String gender,
      String name,
      String petClass,
      String petSpecies,
      String description,
      String owner,
      String ownerUid,
      String ownerEmail,
      Position missingLocation,
      String ownerPhotoUrl) async {
    try {
      String postId = const Uuid().v1();

      String photoUrl = await StorageMethods.uploadImageToStorage(
          'missingPets', file, postId, true);

      Position latLon = missingLocation;
      GeoFirePoint myLocation =
          geo.point(latitude: latLon.latitude, longitude: latLon.longitude);

      // testing purposes
      // GeoFirePoint myLocation =
      //     geo.point(latitude: 1.452804, longitude: 110.417855);

      MissingPet registeredPet = MissingPet(
          postId: postId,
          uid: uid,
          photoUrl: photoUrl,
          gender: gender,
          name: name,
          petClass: petClass,
          petSpecies: petSpecies,
          description: description,
          location: myLocation.data,
          date: FieldValue.serverTimestamp(),
          owner: owner,
          ownerUid: ownerUid,
          ownerEmail: ownerEmail,
          ownerPhotoUrl: ownerPhotoUrl);

      await _firestore
          .collection('missingPets')
          .doc(postId)
          .set(registeredPet.toJson());

      await AuthMethods.updateUser(
          'missingPetList', FieldValue.arrayUnion([postId]));

      return ('success');
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String> deleteDocument(
      String collectionName, String postID) async {
    try {
      if (collectionName == 'registeredPets') {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .update({
          'petList': FieldValue.arrayRemove([postID])
        });
      } else {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .update({
          'missingPetList': FieldValue.arrayRemove([postID])
        });
      }

      final CollectionReference collection =
          _firestore.collection(collectionName);

      await collection.doc(postID).delete();

      await StorageMethods.removeImageFromStorage(collectionName, postID);

      return ('success');
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('registeredPets').doc(postId).update(
          {
            'likes': FieldValue.arrayRemove([uid])
          },
        );
      } else {
        await _firestore.collection('registeredPets').doc(postId).update(
          {
            'likes': FieldValue.arrayUnion([uid])
          },
        );
      }
      return 'success';
    } catch (e) {
      return (e.toString());
    }
  }
}
