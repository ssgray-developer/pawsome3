import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawsome/model/user.dart' as model;

class AuthMethods {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails(String? userUid) async {
    if (userUid == null) {
      User currentUser = _auth.currentUser!;

      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(currentUser.uid).get();

      return model.User.fromSnapshot(snapshot);
    } else {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(userUid).get();

      return model.User.fromSnapshot(snapshot);
    }
  }

  static Future<String> authenticateUser(String email, String password) async {
    User currentUser = _auth.currentUser!;

    try {
      UserCredential result = await currentUser.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: email, password: password));
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String> changePassword(String value) async {
    User currentUser = _auth.currentUser!;

    try {
      await currentUser.updatePassword(value);
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String> updateUser(String key, dynamic value) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({key: value});
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String> registerUser(
      String name, String email, String password) async {
    try {
      //register user
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      model.User user = model.User(
          email: email,
          uid: userCredential.user!.uid,
          username: name,
          chatId: [],
          petList: [],
          missingPetList: []);

      // add user data to firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set(
            user.toJson(),
          );
      return 'success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else {
        return e.message ?? e.toString();
      }
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return 'success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      }
      return e.toString();
    }
  }

  static Future<String> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return 'success';
    } on FirebaseAuthException catch (e) {
      return (e.message ?? e.toString());
    }
  }

  static Future<void> signOutUser() async {
    await _auth.signOut();
  }
}
