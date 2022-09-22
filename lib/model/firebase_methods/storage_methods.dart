import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_downloader/image_downloader.dart';

class StorageMethods {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<String> uploadImageToStorage(
      String childName, Uint8List file, String? postId, bool isPost) async {
    Reference ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);

    if (isPost) {
      // String id = const Uuid().v1();
      ref = ref.child('$postId.jpg');
    }
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  static Future<String> removeImageFromStorage(
      String childName, String fileName) async {
    final image = _storage
        .ref(childName)
        .child(_auth.currentUser!.uid)
        .child('$fileName.jpg');

    try {
      await image.delete();
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String> downloadImage(String url) async {
    try {
      var imageId = await ImageDownloader.downloadImage(url);
      return ('success');
    } catch (e) {
      return e.toString();
    }
  }
}
