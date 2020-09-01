import 'dart:convert';
import 'dart:io';

import 'package:chatapp/models/chat_model.dart';
import 'package:chatapp/services/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class MessageService 
{
  
  String _peerID;
  String _chatID;
  ImagePicker _imagePicker;
  File _file;

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

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }


  Future<void> createFile() async
  {
    String path = await _localPath;
    _file = File('$path/$_chatID.json');
  }

  void writeToFile(List<ChatModel> model)
  {
    if(_file != null)
    {
      try
      {

        List<Map<String, dynamic>> jsonString = List();
        model.forEach((element) 
        {
          jsonString.insert(0, element.toJson());
        });
        _file.writeAsStringSync(json.encode(jsonString));
      }
      catch(e)
      { 
        print(e);
      }
    }
    else
    {
      print("File doesnt exist");
    }
  }

  void addToFile(ChatModel model)
  {
    if(_file != null)
    {
      try
      {
        List<ChatModel> content = readFile();
        content.add(model);
        var jsonString = List();
        content.forEach((element) 
        {
          jsonString.add(element.toJson());
        });
        _file.writeAsStringSync(json.encode(jsonString));
      }
      catch(e)
      {
        print(e);
      }
    }
  }

  Future<void> deleteMessage(int timestamp) async
  {
    print("delted");
    await Firestore.instance.collection("chats").document(_chatID).collection("messages").document(timestamp.toString()).delete();
  }

  List<ChatModel> readFile()
  {
    List<ChatModel> models = List();
    print(_file);
    if(_file != null)
    {
      try
      {
        List<dynamic> jsonFileContent = json.decode(_file.readAsStringSync());
        for(int counter = 0; counter < jsonFileContent.length; counter++)
        {
          models.insert(0, ChatModel.fromJson(jsonFileContent[counter]));
        }
      }
      catch(e)
      {
        print(e);
        return List();
      }

    }
    return models;
  }

  Stream getStream()
  {
    return Firestore.instance.collection("chats").
      document(_chatID).
      collection("messages").
      orderBy("timestamp", descending: true).
      where("from", isEqualTo: _peerID).
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

  Future<void> sendMessage(String content, int type)
  {
    print("message sent");
    int time = DateTime.now().millisecondsSinceEpoch;
    ChatModel model = ChatModel.fromJson(
      {
        'from' : Auth.getUserID(),
        'content' : content,
        'timestamp' : time,
        'type' : type,
        'received' : false,
        'liked' : false
      }
    );
    var modellist = readFile();
    modellist.add(model);
    writeToFile(modellist);
    var docRef = Firestore.
      instance.
      collection("chats").
      document(_chatID).
      collection("messages").
      document(time.toString());

    return Firestore.instance.runTransaction((transaction) async 
    {
      await transaction.set(docRef, model.toJson());
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
