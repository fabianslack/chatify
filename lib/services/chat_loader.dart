import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'authentication.dart';

class ChatLoader
{

  Stream getStream()
  {
    return Firestore.instance.collection("users").document(Auth.getUserID()).snapshots();
  }

  static void addFriend(String friendID)async
  {
    Auth _auth =  Auth();
    FirebaseUser user = await _auth.getCurrentUser();
    String name = await Firestore.instance.collection("users").document(friendID).get().then((value) => 
      value.data["username"]);
    Firestore.instance.collection("users").document(user.uid).updateData(
      {
        "friends": FieldValue.arrayUnion([name]), 
        "friendsId" : FieldValue.arrayUnion([friendID])
      });

    Firestore.instance.collection("users").document(friendID).updateData(
    {
      "friends": FieldValue.arrayUnion([name]),
      "friendsId" : FieldValue.arrayUnion([friendID])
    });

  }

  

  static void addRequest(String friendId)
  {
    Firestore.instance.collection("users").document(Auth.getUserID()).updateData({"requests" : FieldValue.arrayUnion([friendId])});
  }

  static Stream getStreamRequests()
  {
    return Firestore.instance.collection("users").document(Auth.getUserID()).snapshots();
  }

  static void removeRequest(String id)
  {
    Firestore.instance.collection("users").document(Auth.getUserID()).updateData({"requests": FieldValue.arrayRemove([id])});
  }

  static Stream getStreamChat(String id)
  {
    return Firestore.instance.collection("chats").document(id).collection("messages").orderBy("timestamp", descending: true).limit(20).snapshots();
  }

  void sendMessage(String id, String content)
  {
    if(content.trim() != '')
    {
      var docRef = Firestore.instance.collection("chats").
      document(id).collection("messages").document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async
      {
        await transaction.set(docRef, 
        {
           'from' : Auth.getUserID(),
           'content' : content,
           'timestamp': DateTime.now().millisecondsSinceEpoch
        });
      });
    }
  }

  static Future<String> getUsernameForUID(String uid) async
  {
    return await Firestore.instance.collection("users").document(uid).get().then((value)
    {
      return value.data["username"];
    } );
  }

  void setChatRoom(String id)
  {

  }
}