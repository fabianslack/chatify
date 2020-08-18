import 'package:chatapp/services/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService {
  
  String _chatID;

  MessageService(this._chatID);

  Stream getStream()
  {
    return Firestore.instance.collection("chats").
      document(_chatID).
      collection("messages").
      orderBy("timestamp", descending: true).
      limit(20).
      snapshots();
  }

  void setRead(int timestamp)
  {
    Firestore.
    instance.
    collection("chats").
    document(_chatID).
    collection("messages").
    document(timestamp.toString()).
    updateData(
      {
        'received' :true
      }
    );
  }

  void sendMessage(String content, int type)
  {
    int time = DateTime.now().millisecondsSinceEpoch;
    var docRef = Firestore.
      instance.
      collection("chats").
      document(_chatID).
      collection("messages").
      document(time.toString());

    Firestore.instance.runTransaction((transaction) async 
    {
      await transaction.set(docRef, 
      {
        'from' : Auth.getUserID(),
        'content' : content,
        'timestamp' : time,
        'type' : type,
        'received' : false,
        'liked' : false
      });
    });
  }

  void likeMessage(int timestamp, bool liked)
  {
    Firestore.
    instance.
    collection("chats").
    document(_chatID).
    collection("messages").
    document(timestamp.toString()).
    updateData(
      {
        'liked' : liked
      }
    );
  }


}
