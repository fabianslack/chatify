import 'dart:async';
import 'dart:developer';

import 'package:chatapp/pages/home/chat.dart';
import 'package:chatapp/services/authentication.dart';
import 'package:chatapp/services/friends_service.dart';
import 'package:chatapp/services/message_service.dart';
import 'package:flutter/material.dart';

class ChatPreview extends StatefulWidget 
{
  var _ref;
  String _username;
  bool _message;
  String _id;

  ChatPreview(this._username, this._ref, this._message, this._id);

  @override
  _ChatPreviewState createState() => _ChatPreviewState();
}

class _ChatPreviewState extends State<ChatPreview> 
{
  
  Timer _timer;

  bool _online;
  String _imageRef;
  double _flex = 100;
  double _secondFlex = 100;

  bool _swipeRight = false;
  bool _swipeLeft = false;

  @override
  void initState() 
  {
    super.initState();
    _online = false;
    _timer = Timer.periodic(Duration(minutes: 1), (timer) => onlineState());
    onlineState();
  }

  @override
  void dispose() 
  {
    super.dispose();
    _timer.cancel();
  }

  void loadProfileImage() 
  {
    FriendsService.loadImage(widget._id).then((value) 
    {
      setState(() {
        _imageRef = value;
      });
    });
  }

  void onlineState() 
  {
    loadProfileImage();
    MessageService.getOnlineState(widget._id).then((value) 
    {
      setState(() {
        _online = value;
      });
    });
  }

  void handleTap() 
  {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChatPage(widget._username, _imageRef, widget._id),
    ));
  }

  Widget getContent()
  {
    DateTime time = widget._message
    ? DateTime.fromMillisecondsSinceEpoch(widget._ref["timestamp"])
    : DateTime(0);
    String _time = time.hour.toString() + ":" + (time.minute.toString().length > 1 ? time.minute.toString() : "0" + time.minute.toString());
    return Row(
      children: <Widget>[
        Stack(
          children: [
            Hero(
              child: CircleAvatar(
                backgroundImage: _imageRef != null ? NetworkImage(_imageRef) : AssetImage("assets/logo.png"),
                radius: 24,
              ),
              tag: 'image'+widget._username,
            ),
            Positioned(
              bottom: 0.0,
              right: 0.0,
              child: Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _online ? Colors.green : Colors.red
                )
              )
            )
          ],
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Hero(
                    tag: widget._username,
                    child: Text(widget._username,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.black
                      )
                    ),
                  ),
                  Text(
                    _time,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Colors.grey[600]
                    ),
                  ),
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      widget._message ? widget._ref["content"] : "",
                      overflow: TextOverflow.ellipsis,
                      style:  TextStyle(
                        fontSize: 14, 
                        color: Colors.grey
                      )
                    ),
                  ),
                  widget._message && !widget._ref["received"] && widget._ref["from"] != Auth.getUserID()
                  ? Container(
                    height: 15,
                    width: 15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.blue
                    ),
                  )
                  : Container()
                ]
              )
            ],
          )
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) 
  {

    return GestureDetector(
      onHorizontalDragUpdate: (drag) 
      {
        setState(() {
          print(_secondFlex.toString() + "   " + _flex.toString());
          if(drag.primaryDelta > 0) // rechts
          {
            _secondFlex -= drag.primaryDelta;
            _swipeRight = true;
          }
          
          else if(drag.primaryDelta < 0) // links
          {
            _flex += drag.primaryDelta;
            _swipeLeft = true;
          }

          if(_swipeRight && drag.primaryDelta < 0)
          {
            _secondFlex -= drag.primaryDelta;
            _flex = 100;
            if(_secondFlex > 130)
            {
              _swipeRight = false;
            }
          }

          if(_swipeLeft && drag.primaryDelta > 0)
          {
            _flex += drag.primaryDelta;
            _secondFlex = 100;
            if(_flex > 130)
            {
              _swipeLeft = false;
            }
          }
          
          if(_flex < 80)
          {
            _flex = 80;

          }

          if(_secondFlex < 80)
          {
            _secondFlex = 80;
          }
          
       });
      },
      child: Row(
        children: [
          Expanded(
            flex: 100 - _secondFlex.toInt(),
            child: SizedBox(
              width: 0.0,
              height: 60,
              child: FlatButton(
                color: Colors.red,
                child: FittedBox(
                  child: Text(
                    "Left",
                    style: TextStyle(
                      color: Colors.black
                    )
                  ),
                ),
              onPressed: () {},
              ),
            ),
          ),
          Expanded(
            flex: _flex.toInt(),
            child: GestureDetector(
              onTap: () => handleTap(),
              child: Container(
              margin: const EdgeInsets.symmetric(vertical: 7),
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: getContent()
              ),
            ),
          ),
          Expanded(
            flex: 100 - _flex.toInt(),
            child: SizedBox(
              width: 0.0,
              height: 60,
              child: FlatButton(
                color: Colors.grey[200],
                child: FittedBox(
                  child: Text(
                    "Right",
                    style: TextStyle(
                      color: Colors.black
                    )
                  ),
                ),
              onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
