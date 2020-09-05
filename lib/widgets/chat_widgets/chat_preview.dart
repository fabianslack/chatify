import 'dart:async';
import 'dart:developer';

import 'package:chatapp/pages/home/chat.dart';
import 'package:chatapp/pages/home/share_page.dart';
import 'package:chatapp/services/authentication.dart';
import 'package:chatapp/services/friends_service.dart';
import 'package:chatapp/services/message_service.dart';
import 'package:flutter/cupertino.dart';
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
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (context) => ChatPage(widget._username, _imageRef, widget._id),
    ));
  }

  void handleLongTap()
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
          child: SharePage(widget._id),
        );
      }
    );
  }

  Widget getImage()
  {
    return Container(
      height: 55,
      width: 55,
      child: Stack(
        children: [
          CircleAvatar(
            backgroundImage: _imageRef != null ? NetworkImage(_imageRef) : AssetImage("assets/logo.png"),
            radius: 28,
          ),
          _online ? Positioned(
            bottom: 0.0,
            right: 0.0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white
              ),
              child: Center(
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green
                  )
                ),
              ),
            )
          ) : Container()
        ],
      ),
    );
  }

  Widget getContent()
  {
    DateTime time = widget._message
    ? DateTime.fromMillisecondsSinceEpoch(widget._ref["timestamp"])
    : DateTime(0);
    String _time = time.hour.toString() + ":" + (time.minute.toString().length > 1 ? time.minute.toString() : "0" + time.minute.toString());
    return Row(
      children: <Widget>[
        getImage(),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget._username,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Colors.black
                      )
                    ),
                    Text(
                      _time,
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 14
                      )
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5,),
              Text(
                widget._message ? widget._ref["type"] == 0 ? widget._ref["content"] : "Image" : "",
                overflow: TextOverflow.ellipsis,
                style:  TextStyle(
                  fontSize: 16, 
                  color: Colors.grey
                )
              )
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) 
  {

    return GestureDetector(
      onTap: () => handleTap(),
      onLongPress: () => handleLongTap(),
      child: Container(
        height: 75,
        child: getContent()
        ),
    );
  }
}