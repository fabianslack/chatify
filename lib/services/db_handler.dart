import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Db {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final Future<String> uid =
      _firebaseAuth.currentUser().then((value) => value.uid);

  Future<DocumentReference> getSnapshot() async {
    return Firestore.instance.collection("users").document(await uid);
  }

  Future<String> getUsername() async {
    var snapshot = await getSnapshot();

    return snapshot.get().then((value) => value["username"]);
  }

  Future<void> setUsername(String username) async {
    var snapshot = await getSnapshot();
    snapshot.updateData({'username': username});
  }

  Future<void> setUserImageRef(String downloadUrl) async {
    var snapshot = await getSnapshot();
    snapshot.updateData({"profileImage": downloadUrl});
  }

  Future<String> getUserImageRef() async {
    var snapshot = await getSnapshot();

    return snapshot.get().then((value) => value["profileImage"]);
  }
}
