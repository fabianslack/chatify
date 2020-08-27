import 'dart:io';

import 'package:chatapp/services/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class MessageService 
{
  
  String _peerID;
  String _chatID;
  ImagePicker _imagePicker;

  MessageService(this._peerID)
  {
    _imagePicker = ImagePicker();
    _getChatId();
  }

  void _getChatId()
  {
    String id = Auth.getUserID();
    if(_peerID.hashCode >= id.hashCode)
    {
      _chatID = '' + (_peerID.hashCode - id.hashCode).toString();
    }
    else
    {
      _chatID = '' + (id.hashCode - _peerID.hashCode).toString();
    }
  }

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
        'received' : true
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

  static Stream getHomeStream(String roomID)
  {
    return Firestore.
    instance.
    collection("chats").
    document(roomID).
    collection("messages").
    orderBy("timestamp", descending: true).
    limit(1).
    snapshots();
  }

  static Future<bool> getOnlineState(String id)
  {
    return Firestore.instance.collection("users").document(id).get().then((value) => value["online"]); 
  }

  static Stream getOnlineStatus(String id)
  {
    return Firestore.
    instance.
    collection("users").
    document(id).
    snapshots();
  }

  void selectImage() async
  {
    File _imageFile;
    final pickedFile = await _imagePicker.getImage(source: ImageSource.gallery);
    if(pickedFile.path != null)
    {
      _imageFile = File(pickedFile.path);
    }

    if(_imageFile != null)
    {
      uploadFile(_imageFile);
    }
  }

  void uploadFile(File _imageFile) async
  {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference _ref = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = _ref.putFile(_imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl)
    {
      sendMessage(downloadUrl, 1);
    });
  }
}
