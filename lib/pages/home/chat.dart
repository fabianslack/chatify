import 'dart:async';
import 'dart:io';

import 'package:chatapp/services/authentication.dart';
import 'package:chatapp/services/message_service.dart';
import 'package:chatapp/widgets/chat_image.dart';
import 'package:chatapp/widgets/chat_message_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'share_page.dart';

/// This class add the chatting funcionality to the app.
/// When an object is created, a new unique ChatId is calculated.
/// When a message is sent, the content, the timestamp and the Sender-ID are saved the database 
/// under the path chats/ChatId/timestamp/
class ChatPage extends StatefulWidget 
{
  final String _name;
  final String id;
  final String _imageRef;
  ChatPage(this._name, this._imageRef, this.id);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> 
{
  double _width;

  MessageService _service;

  bool _textContainsText = false;
  String peerId;
  String chatID;
  File _imageFile;
  bool _online;
  Timer _timer;

  bool _sharePressed = false;

  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  ImagePicker _imagePicker;


  @override
  void initState()
  {
    super.initState();
    _online = false;
    chatID = '';
    peerId = widget.id;
    init();
    _service = MessageService(chatID);
    _imagePicker = ImagePicker();
    _timer = Timer.periodic(Duration(minutes: 1), (timer) => onlineState());
    onlineState();
  }

  @override
  void dispose()
  {
    super.dispose();
    if(_timer != null)
    {
      _timer.cancel();
    }
  }

  void init() 
  {
    String id = Auth.getUserID();
    if(peerId.hashCode >= id.hashCode)
    {
      chatID = '' + (peerId.hashCode - id.hashCode).toString();
    }
    else
    {
      chatID = '' + (id.hashCode - peerId.hashCode).toString();
    }
  }

  void getImage() async
  {
    final pickedFile = await _imagePicker.getImage(source: ImageSource.gallery);
    if(pickedFile.path != null)
    {
      _imageFile = File(pickedFile.path);
    }

    if(_imageFile != null)
    {
      uploadFile();
    }
  }

  void onlineState()
  {
    MessageService.getOnlineState(peerId).then((value) 
    {
      setState(() {
        _online = value;
      });
    });
  }

  void uploadFile() async
  {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference _ref = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = _ref.putFile(_imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl)
    {
      _service.sendMessage(downloadUrl, 1);
    });
  }

  void onSendClicked()
  {
    _service.sendMessage(_controller.text.trim(), 0);
    _scrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);

    _controller.clear();
    setState(() {
      _textContainsText = false;
    });
  }

  void onMessageDoubleTap(int timestamp, bool liked)
  {
    _service.likeMessage(timestamp, liked);
  }

  Widget getAppBar()
  {
    return AppBar(
      titleSpacing: 0,
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                new PageRouteBuilder(
                  opaque: false,
                  barrierDismissible:true,
                  pageBuilder: (BuildContext context, _, __) {
                    return Hero(
                      tag: widget._imageRef,
                      flightShuttleBuilder: (flightContext, animation, direction,
                          fromContext, toContext) {
                        return AlertDialog(
                          content: Image.network(widget._imageRef),
                        );
                      },
                      child: AlertDialog(
                        content: Image.network(widget._imageRef),
                      )
                    );
                  }
                )
            );
            },
            child: CircleAvatar(
              backgroundImage: widget._imageRef != null ? NetworkImage(widget._imageRef) : AssetImage("assets/logo.png")
              )
          ),
          SizedBox(width: 10,),
          _online ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
              widget._name,
              style: TextStyle(
                fontSize: 22,
                color: Colors.black
                ),
              ),
              Text(
                "online",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600]
                )
              )
            ],
          ) : Hero(
            tag: '_'+widget._name,
              child: Text(
              widget._name,
              style: TextStyle(
                fontSize: 24,
                color: Colors.black
              ),
            ),
          ),
        ],
      ),
      leading: IconButton(
        icon: Icon(
          Icons.navigate_before,
          size: 40,
          color: Colors.blueAccent,
        ),
        onPressed: () => Navigator.pop(context),
      ),
     
      bottom: PreferredSize(
        child: Container(
          color: Colors.grey[200],
          height: 1,
        ),
        preferredSize: Size.fromHeight(1.0),
      )
    );
  }

  Widget getTextField()
  {
    return Flexible(
      child: Container(
        padding: EdgeInsets.only(left: 10),
        child: TextField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          style: TextStyle(
            color: Colors.black,
            fontSize: 22
          ),
          controller: _controller,
          decoration: InputDecoration(
            isDense: true,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: 'Chat ...',
            hintStyle: TextStyle(
              color: Colors.black,
              fontSize: 22
            ),
            suffixIcon: !_textContainsText ? Container() : GestureDetector(
              onTap: () => onSendClicked(),
              child: Container(
                height: 30,
                width: 55,
                padding: const EdgeInsets.only(right: 10),
                child: Center(
                  child: Text(
                    "Send",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                ),
              ),
            )
          ),
          onChanged: (value)
          {
            setState(()
            {
              value.length > 0 ? _textContainsText = true : _textContainsText = false;
            });
          },
        ),
      ),
    );
  }

  Widget getCameraIcon()
  {
    return !_textContainsText ? Container(
      width: 40,
      child: IconButton(
        onPressed: () {},
        icon: Icon(
          Icons.camera_alt,
          size: 27,
          color: Colors.grey[700],
        ),
      ),
    ) : Container();
  }

  Widget getShareButton()
  {
    return Padding(
      padding: const EdgeInsets.fromLTRB(3, 2, 0, 2),
      child: Container(
        width: 37,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue[300], Colors.blue[600]
            ]
          )
        ),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 32,
            ),
          ),
          
        ),
      ),
    );
  }

  Widget getAudioButton()
  {
    return !_textContainsText ? GestureDetector(
      onTap: () {},
      child: Icon(
        Icons.mic,
        color: Colors.grey[700],
        size: 27,
      ),
    ) : Container();
  }

  Widget getBottomBody()
  {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 10, 5),
      child: Container(
        height: 50,
        width: double.infinity,
        child: Row(
          children: [
            getShareButton(),
            SizedBox(width: 5,),
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.grey[200]
                  ),
                  borderRadius: BorderRadius.circular(30)
                ),
                height: 42,
                child: Row(
                  children: [
                      getTextField(),
                      getAudioButton(),
                      getCameraIcon()
                  ],
                ) ,
              ),
            )
          ],
        ),
      ),
    );
    return Container(
     padding:  EdgeInsets.fromLTRB(5, 5, (_textContainsText ? 5 : 0), 5),
     width: _width,
     height: 55,
     decoration: BoxDecoration(
       border: Border(
         top: BorderSide(
           color: Colors.grey[200],
           width: 1
         )
       ),
       color: Colors.white,
     ),
     child: Row(
       children: <Widget>[
         getShareButton(),
         getTextField(),
         getAudioButton(),
         getCameraIcon()
       ]
     ),
      );
  }

  Widget getChatColumn()
  {
    return Expanded(
      child: StreamBuilder(
      stream: _service.getStream(),
      builder: (context, snapshot) => snapshot.data != null ? ListView.builder(
        controller: _scrollController,
        reverse: true,
        physics: BouncingScrollPhysics(),
        itemCount: snapshot.data.documents.length,
        itemBuilder: (context, index) 
        {
          var ref = snapshot.data.documents[index];
          if(ref['from'] != Auth.getUserID())
          {
            _service.setRead(ref['timestamp']);
          }
          if(ref['type'] == 0)
          {
            return ChatMessage(ref, onMessageDoubleTap);
          }
          else if(ref['type'] == 1)
          {
            return ChatImage(ref);
          }
          return Container();
        }
      ) : Container(),
        
      ),
    );
  }


  Widget getBody()
  {
    return Column(
      children: <Widget>[
       getChatColumn(),
       _sharePressed ? SharePage() : getBottomBody(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    _width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: getAppBar(),
      body: getBody(),
      backgroundColor: Colors.white,
    );
  }
}