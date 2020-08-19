import 'package:cloud_firestore/cloud_firestore.dart';

import 'authentication.dart';

class FriendsService
{
  void addFriend(String friendID) async
  {
    String name = await Firestore.instance.collection("users").document(friendID).get().then((value) => 
      value.data["username"]);
    String username = await Firestore.instance.collection("users").document(Auth.getUserID()).get().then((value) => 
      value.data["username"]);
    Firestore.instance.collection("users").document(Auth.getUserID()).updateData(
      {
        "friends": FieldValue.arrayUnion([name]), 
        "friendsId" : FieldValue.arrayUnion([friendID])
      });

    Firestore.instance.collection("users").document(friendID).updateData(
    {
      "friends": FieldValue.arrayUnion([username]),
      "friendsId" : FieldValue.arrayUnion([Auth.getUserID()])
    });
  }

  void addRequest(String friendID)
  {
    Firestore.
    instance.
    collection("users").
    document(friendID).
    updateData(
    {
      "requests" : FieldValue.arrayUnion([Auth.getUserID()])
    });
  }

  void removeRequest(String friendID)
  {
    Firestore.
    instance.
    collection("users").
    document(Auth.getUserID()).
    updateData(
    {
      "requests": FieldValue.arrayRemove([friendID])
    });
  }

  Stream getStream()
  {
    return Firestore.
    instance.
    collection("users").
    document(Auth.getUserID()).
    snapshots();
  }

  static Future<String> loadImage(String friendId)
  {
    return Firestore.instance.collection("users").document(friendId).get().then((value) => value["profileImage"]);
  }

  Future<String> getUsernameForId(String id) async
  {
    return Firestore.instance.collection("users").document(id).get().then((value) => value["username"]);
  }

  Future<bool> isFriendOnline(String friendID) async
  {
    return Firestore.instance.collection("users").document(friendID).get().then((value) => value["online"]);
  }
}