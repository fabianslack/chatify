import 'dart:async';
import 'package:camera/camera.dart';
import 'package:chatapp/models/chat_model.dart';
import 'package:chatapp/pages/home/camera_page.dart';
import 'package:chatapp/services/authentication.dart';
import 'package:chatapp/services/message_service.dart';
import 'package:chatapp/widgets/chat_widgets/chat_image.dart';
import 'package:chatapp/widgets/chat_widgets/chat_message_widget.dart';
import 'package:flutter/material.dart';
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

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin  
{

  MessageService _service;

  bool _textContainsText = false;
  bool _camera = false;
  bool _online;
  Timer _timer;

  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();

  List<CameraDescription> _cameras;

  @override
  void initState()
  {
    super.initState();
    _service = MessageService(widget.id);
    loadCameras();
    _online = false;
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
    _controller.dispose();
    _service.onClose();
    _scrollController.dispose();
  }

  void loadCameras() async
  {
    _cameras = await availableCameras();
  }

  void onlineState()
  {
    MessageService.getOnlineState(widget.id).then((value) 
    {
      setState(() {
        _online = value;
      });
    });
  }

  void onSendClicked()
  {
    _service.sendMessage(_controller.text.trim(), 0);
   navigateToBottom();
    _controller.clear();
    setState(() {
      _textContainsText = false;
    });
  }

  void navigateToBottom()
  {
     _scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 250),
      curve: Curves.linear);
  }

  void onMessageDoubleTap(int timestamp, bool liked)
  {
    //_service.likeMessage(timestamp, liked);
  }

  void onCameraDismissed()
  {
    setState(() {
      _camera = false;
    });
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
    return Expanded(
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
                      fontSize: 18
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
        onPressed: () 
        {
          setState(() {
            _camera = true;
          });
        },
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
            onTap: () 
            {
              showModalBottomSheet(
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)
                ),
                context: context,
                builder: (context)
                {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: SharePage(widget.id),
                  );
                }
              );
            },
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
  }

  Widget getChatColumn()
  {
    return Expanded(
      child: StreamBuilder(
        stream: _service.stream,
        builder: (context, snapshot)
        {
        return snapshot.data != null ? ListView(
          reverse: true,
          controller: _scrollController,
          physics: BouncingScrollPhysics(),
          children: [
            CustomScrollView(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              slivers:[
                SliverList(
                  delegate: SliverChildListDelegate(
                    List.generate(snapshot.data.length, (index)
                    {
                      ChatModel model = snapshot.data[index];
                      bool showImage = false;
                      if(index != snapshot.data.length-1)
                      {
                        if(snapshot.data[index+1].from() == Auth.getUserID() && model.from() != Auth.getUserID())
                        {
                          // letzte nachricht vom anderen user
                          showImage = true;
                        }
                      }
                      else
                      {
                        if(model.from() != Auth.getUserID())
                        { 
                          showImage = true;
                        }
                      }
                      if(model.type() == 0)
                      {
                        return ChatMessage(model, onMessageDoubleTap, 1, showImage, widget._imageRef);
                      }
                      else if(model.type() == 1)
                      {
                        return ChatImage(model);
                      }
                      return Container();
                      }
                    ),
                  ),
                )
                
              ]
            )
          ],
        ) : Container();
        }
      )
    );
  }


  Widget getBody()
  {
    return Column(
      children: <Widget>[
      getChatColumn(),
      getBottomBody(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    return Stack(
      children:[ Scaffold(
        appBar: getAppBar(),
        body: getBody(),
        backgroundColor: Colors.white,
      ),
      _camera ? CameraPage(_cameras, widget.id, onCameraDismissed) : Container()
      ]
    );
  }
}