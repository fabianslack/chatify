import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'authentication.dart';

class FriendsService
{
  StreamController _controller = StreamController();
  StreamSubscription _streamSubscription;

  FriendsService()
  {
    listen();
  }

  void listen()
  {
    _streamSubscription = Firestore.instance.collection("users").document(Auth.getUserID()).collection("friends").orderBy("timestamp", descending: true).snapshots().listen((event) 
    { 
      _controller.sink.add(event);
    });
  }

  void onClose()
  {
    _streamSubscription.cancel();
    _controller.close();
  }

  Stream get stream => _controller.stream;

  List<dynamic> _friends = List();

  void addFriend(String friendID) async
  {
    String name = await Firestore.instance.collection("users").document(friendID).get().then((value) => 
      value.data["username"]);
    String username = await Firestore.instance.collection("users").document(Auth.getUserID()).get().then((value) => 
      value.data["username"]);
    
  }

  Future<List<dynamic>> getStories() async
  {
    var result = List();
    for(var element in _friends)
    {
      if(await hasStory(element))
      {
        result.add(element);
      }
    }
    return result;
  }

  Stream getStream()
  {
    return Firestore.instance.collection("users").document(Auth.getUserID()).collection("friends").orderBy("timestamp", descending: true).snapshots();
  }

  Future<bool> hasStory(String id) async
  {
    return (await Firestore.instance.collection("users").document(id).get().then((value) => value["stories"].length > 0));
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

  static Future<String> loadImage(String friendId)
  {
    return Firestore.instance.collection("users").document(friendId).get().then((value) => value["profileUrl"]);
  }

  static Future<String> getUsernameForId(String id) async
  {
    return Firestore.instance.collection("users").document(id).get().then((value) => value["username"]);
  }

  static Future<String> loadStoryImage(String id)
  {
    return Firestore.instance.collection("users").document(id).get().then((value) => value["stories"][0]);
  }

  Future<bool> isFriendOnline(String friendID) async
  {
    return Firestore.instance.collection("users").document(friendID).get().then((value) => value["online"]);
  }
}