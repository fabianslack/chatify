import 'dart:async';
import 'dart:io';

import 'package:chatapp/models/chat_model.dart';
import 'package:chatapp/services/authentication.dart';
import 'package:chatapp/services/file_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class MessageService 
{
  
  String _peerID;
  String _chatID;
  ImagePicker _imagePicker;
  FileService _fileService;
  StreamController<List<ChatModel>> _controller = StreamController();
  bool _closed = false;
  List<ChatModel> _messages = List();
  

  MessageService(this._peerID)
  {
    _imagePicker = ImagePicker();
    _getChatId();
    _fileService = FileService("${Auth.getUserID()}$_peerID");
    _fileService.createFile().then((value)
    {
      _messages = _fileService.readFile();
      _controller.sink.add(_messages);
      listen();
    });
  }

  Stream<List<ChatModel>> get stream => _controller.stream;

  void onClose()
  {
    _closed = true;
    _fileService.writeToFile(_messages);
    _controller.close();
  }

  void listen()
  {
    if(!_closed)
    {
      getStream().listen((event) 
      { 
        List<ChatModel> models = List();
        for(int counter = 0; counter < event.documents.length; counter++)
        {
          ChatModel model = ChatModel.fromDocumentSnapshot(event.documents[counter]);
          if(model.from() != Auth.getUserID() && !_messages.contains(model))
          {
            models.add(model);
            _messages.add(model);
          }
        }
        _controller.sink.add(_messages);
        deleteMessage();
      });
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
  
  void deleteMessage()
  {
    Firestore.instance.collection("chats").document(_chatID).collection("messages").getDocuments().then((value)
    {
      for(int counter = value.documents.length-2; counter >= 0; counter--)
      {
        value.documents[counter].reference.delete();
      }
    });
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

  Stream getPeerStream()
  {
    return Firestore.instance.collection("users").document(_peerID).snapshots();
  }

  void setWriting(bool isWriting)
  {
    Firestore.instance.collection("users").document(_peerID).updateData(
      {
        'writing' : isWriting ? _peerID : 'null'
      }
    );
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
