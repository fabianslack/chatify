import 'dart:async';
import 'dart:io';
import 'package:chatapp/models/chat_model.dart';
import 'package:chatapp/services/authentication.dart';
import 'package:chatapp/services/file_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gallery_saver/gallery_saver.dart';
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
  /// List of messages sent
  List<ChatModel> _messages = List();
  List<ChatModel> _images = List();

  StreamSubscription _streamSubscription;
  StreamSubscription _streamReadSubscription;

  
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
      listenRead();
    });
  }

  /// get the stream containing all messages
  Stream<List<ChatModel>> get stream => _controller.stream;

  /// should be called when user navigates back to home screen
  void onClose()
  {

    _messages.forEach((element) 
    { 
      if(element.type() == 2)
      {
        _fileService.saveImageToFile(element).then((value)
        {
          element.setContent(value);
          element.setType(1);
        });
      }
    });
    _images.forEach((element) {deleteImage(element.content());});
    _fileService.writeToFile(_messages);
    _streamSubscription.cancel();
    _streamReadSubscription.cancel();
    _controller.close();
  }


  /// listens for new messages and adds them to _messages and _controller 
  /// deletes all messsages except last one from firebase
  void listen()
  {
    _streamSubscription = Firestore.instance.collection("chats").
    document(_chatID).
    collection("messages").
    where("from", isEqualTo: _peerID).
    snapshots().
    listen((event) async
    {   
      if(event.documents.length > 0 && event.documents != null)
      {
        for(int counter = 0; counter < event.documents.length; counter++)
        {
          ChatModel model = ChatModel.fromDocumentSnapshot(event.documents[counter]);
          if(model.type() == 2 && !_messages.contains(model))
          {
            _messages.add(model);
            _images.add(model);
            GallerySaver.saveImage(model.content());
          }
          else if(!_messages.contains(model))
          {
              _messages.add(model);
          }
        }
        _controller.sink.add(_messages);
        setRead();
        deleteMessage();
      }
    });
  }

  void listenRead()
  {
    _streamReadSubscription = Firestore.instance.collection("chats").document(_chatID).snapshots().listen((event) 
    {
      print("event");
      if(event.data != null)
      {
        if(_messages.length > 0)
        {
          ChatModel model = _messages.removeLast();
          model.setRead(event.data["$_peerID"]);
          _messages.add(model);
          _controller.sink.add(_messages);
        }
      }
    });

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
  Future<void> deleteMessage()
  {
    return Firestore.instance.collection("chats").document(_chatID).collection("messages").getDocuments().then((value)
    {
      for(int counter = 0; counter < value.documents.length-1; counter++)
      {
        value.documents[counter].reference.delete();
      }
    });
  }

  Future<void> deleteImage(String fileUrl) async
  {
    
    FirebaseStorage.instance.getReferenceFromUrl(fileUrl).then((value) => value.delete());
  }

  void setRead()
  {
    Firestore.instance.collection("chats").document(_chatID).updateData(
      {
        '${Auth.getUserID()}' : true
      }
    );
  }

  void setUnread()
  {
    Firestore.instance.collection("chats").document(_chatID).updateData(
      {
        '$_peerID' : false
      }
    );
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
        'read' : false,
      }
    );
  }

  /// called when message is sent 
  /// add message to firebase and to _controller and _messages
  Future<void> sendMessage(String content, int type) async
  {
    ChatModel model = _createModel(content, type);
    var docRef = Firestore.
      instance.
      collection("chats").
      document(_chatID).
      collection("messages").
      document(model.timestamp().toString());

    var ref = await Firestore.instance.collection("chats").document(_chatID).get();
    if(!ref.exists)
    {   
      Firestore.instance.collection("chats").document(_chatID).setData(
        {
          '$_peerID' : false,
          '${Auth.getUserID()}' : false
        }
      );
    }
    Firestore.instance.collection("users").document(_peerID).collection("friends").document(Auth.getUserID()).setData(
      {
        'id' : Auth.getUserID(),
        'timestamp': model.timestamp()
      }
    );
    Firestore.instance.collection("users").document(Auth.getUserID()).collection("friends").document(_peerID).setData(
      {
        'id' : _peerID,
        'timestamp': model.timestamp()
      }
    );
    if(type == 0)
    {
      _messages.add(model);
      _controller.sink.add(_messages);
    } 
    setUnread();
    return Firestore.instance.runTransaction((transaction) async 
    {
      await transaction.set(docRef, model.toJson());
    });
  }

  
  static String getChatRoomId(String id)
  {
    if(id.hashCode >= Auth.getUserID().hashCode)
    {
      return '' + (id.hashCode - Auth.getUserID().hashCode).toString();
    }
    else
    {
      return '' + (Auth.getUserID().hashCode - id.hashCode).toString();

    }
  }

  /// return the stream for the home page
  static Stream getHomeStream(String id)
  {
    String roomID = getChatRoomId(id);
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
      ChatModel model = _createModel(_imageFile.path, 1);
      print(model.content());
      _messages.add(model);
      _controller.sink.add(_messages);
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
      sendMessage(downloadUrl, 2);
    });
  }
}
