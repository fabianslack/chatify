import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chatapp/models/chat_model.dart';
import 'package:chatapp/services/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class MessageService 
{
  
  String _peerID;
  String _chatID;
  ImagePicker _imagePicker;
  File _file;
  StreamController<List<ChatModel>> _controller = StreamController();
  bool _closed = false;
  List<ChatModel> _messages = List();
  int _lastMessageTime = 0;
  

  MessageService(this._peerID)
  {
    _imagePicker = ImagePicker();
    _getChatId();
    createFile().then((value)
    {
      readFile();
      listen();
    });
  }

  Stream<List<ChatModel>> get stream => _controller.stream;

  void onClose()
  {
    _closed = true;
    writeToFile();
    _controller.close();
  }

  void listen()
  {
    if(!_closed)
    {
      getStream().listen((event) 
      { 
        for(int counter = 0; counter < event.documents.length; counter++)
        {
          ChatModel model = ChatModel.fromDocumentSnapshot(event.documents[counter]);
          if(model.from() != Auth.getUserID())
          {
            deleteMessage(model.timestamp());
            _messages.add(model);
            _controller.sink.add(_messages);
            _lastMessageTime = model.timestamp();
          }
        }
        
      });
    }
  }

  Future<void> createFile() async
  {
    var path = await getApplicationDocumentsDirectory();
    String filepath = p.join(path.path, _peerID + ".json");
    _file = new File(filepath);
    if(!await _file.exists())
    {
      _file.writeAsStringSync(json.encode(new List()));
    }
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

  void writeToFile()
  {
    try
    {
      List<Map<String, dynamic>> jsonString = List();
      _messages.forEach((element) 
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
  
  Future<void> deleteMessage(int timestamp) async
  {
    await Firestore.instance.collection("chats").document(_chatID).collection("messages").document(timestamp.toString()).delete();
  }

  void readFile() 
  {
    try
    {
      List<dynamic> jsonFileContent = json.decode( _file.readAsStringSync());
      for(int counter = 0; counter < jsonFileContent.length; counter++)
      {
        _messages.add(ChatModel.fromJson(jsonFileContent[counter]));
      }
      _controller.sink.add(_messages);
    }
    catch(e)
    {
      print(_file);
      print("error occured: " + e.toString());
      // print(e);
    }
    
  }

  Stream getStream()
  {
    return Firestore.instance.collection("chats").
      document(_chatID).
      collection("messages").
      where("from", isEqualTo: _peerID).
      snapshots();
  }

  // void setRead()
  // {
  //   Firestore.
  //   instance.
  //   collection("chats").
  //   document(_chatID).
  //   collection("messages").
  //   document(_lastMessageTime.toString()).
  //   updateData(
  //     {
  //       'received' : true
  //     }
  //   );
  // }

  ChatModel _createModel(String content, int type)
  { 
    return ChatModel.fromJson(
      {
        'from' : Auth.getUserID(),
        'content' : content,
        'timestamp' : DateTime.now().millisecondsSinceEpoch,
        'type' : type,
        'received' : false,
        'liked' : false
      }
    );
  }

  Future<void> sendMessage(String content, int type)
  {
    ChatModel model = _createModel(content, type);
    var docRef = Firestore.
      instance.
      collection("chats").
      document(_chatID).
      collection("messages").
      document(model.timestamp().toString());
    _messages.add( model);
    _controller.sink.add(_messages);
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
