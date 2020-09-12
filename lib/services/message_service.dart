import 'dart:async';
import 'dart:io';

import 'package:chatapp/models/chat_model.dart';
import 'package:chatapp/services/authentication.dart';
import 'package:chatapp/services/file_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Manages messages sent and saves them to a file @file_service
/// connect to the stream object to listen to messages
class MessageService 
{
  
  /// the id of the peer
  String _peerID;
  /// the generated chatroom-ID
  String _chatID;
  /// iamge picker for picking images
  ImagePicker _imagePicker;
  /// instance of FileService for writing to file
  FileService _fileService;
  /// controller handling all new messages
  StreamController<List<ChatModel>> _controller = StreamController();
  /// determines whether user has left chatroom
  bool _closed = false;
  /// List of messages sent
  List<ChatModel> _messages = List();
  
  /// creates a new MessageService
  /// @required _peerID the id of the peer
  MessageService(this._peerID)
  {
    _imagePicker = ImagePicker();
    _getChatId();
    _fileService = FileService("${Auth.getUserID()}$_peerID", "path.txt");
    // when create complete read file and listen for new messages
    _fileService.createFile().then((value)
    {
      _messages = _fileService.readFile();
      _controller.sink.add(_messages);
      listen();
    });
  }

  /// get the stream containing all messages
  Stream<List<ChatModel>> get stream => _controller.stream;

  /// should be called when user navigates back to home screen
  void onClose()
  {
    _closed = true;
    _fileService.writeToFile(_messages);
    _controller.close();
  }

  /// listens for new messages and adds them to _messages and _controller 
  /// deletes all messsages except last one from firebase
  void listen()
  {
    if(!_closed)
    {
      Firestore.instance.collection("chats").
      document(_chatID).
      collection("messages").
      snapshots().
      listen((event) 
      { 
        if(event.documents.length > 0)
        {
          bool delete = true;
          List<ChatModel> models = List();
          for(int counter = 0; counter < event.documents.length; counter++)
          {
            ChatModel model = ChatModel.fromDocumentSnapshot(event.documents[counter]);
            if(model.from() == Auth.getUserID())
            {
              print("from suer");
              delete = false;
              if(_messages.length > 0)
              {
                ChatModel model2 = _messages.removeLast();
                model2.setReceived(true);
                _messages.add(model2);

              }
            }
            if(model.from() != Auth.getUserID() && !_messages.contains(model))
            {
              models.add(model);
              _messages.add(model);
              setRead(model.timestamp());
            }
            if(model.type() == 1)
            {
              //GallerySaver.saveImage(model.content());
            }
          }
          _controller.sink.add(_messages);
          if(delete)
          {
            deleteMessage();
          }
        }
        // else if(event.documents.length > 0 && event.documents[0]["from"] == Auth.getUserID())
        // {
        //   print("callled");
        //   var models = _fileService.readFile();
        //   for(ChatModel model in models)
        //   {
        //     model.setReceived(true);
        //   }
        //  // _controller.sink.add(models);
        // }
      });
    }
  }

  /// create a unique chatID
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
  
  /// deletes all messages except the last one from firebase
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
  
  /// sets the message to read
  void setRead(int timestamp)
  {
    if(_messages.length != 0)
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
  }

  /// creates a new message model containing all required data
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

  /// called when message is sent 
  /// add message to firebase and to _controller and _messages
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

  /// return the stream for the home page
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

  /// return the stream listening to the peer data
  /// used for checking whether peer is currently writing a new message
  Stream getPeerStream()
  {
    return Firestore.instance.collection("users").document(_peerID).snapshots();
  }

  /// sets the status of the peer
  void setWriting(bool isWriting)
  {
    Firestore.instance.collection("users").document(_peerID).updateData(
      {
        'writing' : isWriting ? _peerID : 'null'
      }
    );
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
