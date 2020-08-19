import 'dart:async';
import 'dart:io';
import 'package:chatapp/services/db_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Storage {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  final Future<String> uid =
      _firebaseAuth.currentUser().then((value) => value.uid);

  setUserImage(String path) async {
    String uidf = await uid;
    final file = File(path);
    StorageTaskSnapshot snapshot = await _firebaseStorage
        .ref()
        .child("users/$uidf/profileimage")
        .putFile(file)
        .onComplete;
    final String downloadUrl = await snapshot.ref.getDownloadURL();
    Db().setUserImageRef(downloadUrl);
  }

}
