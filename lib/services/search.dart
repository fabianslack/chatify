
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'authentication.dart';

class SearchService
{
  Auth _auth = Auth();

  Future<Map<String, String>> getSuggestionsUsers(String suggestion) async
  {
    Map<String, String> result = Map();
    await Firestore.instance.
    collection("users").
    orderBy("username").
    startAt([suggestion]).
    endAt([suggestion + '\uf8ff']).getDocuments().then((value) => value.documents.forEach((element) {
      result.putIfAbsent(element.data["id"], () => element.data["username"]);
    }));
    return result.length > 20 ? result : result;
  }

  Future<bool> checkIfUserIsFriend(String userID) async
  {
    FirebaseUser user = await _auth.getCurrentUser();
    return Firestore.instance.collection("users").document(user.uid).get().then((value) => value.data[userID] != null);
  }

  Future<String> getNameForId(String id) async
  {
    return await Firestore.instance.collection("users").document(id).get().then((value) => value.data["username"]);
  }
}