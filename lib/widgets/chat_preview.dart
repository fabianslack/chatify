import 'dart:async';

import 'package:chatapp/pages/home/chat.dart';
import 'package:chatapp/services/authentication.dart';
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

  void onlineState()
  {
    MessageService.getOnlineState(widget._id).then((value) 
    {
      setState(() 
      {
        _online = value;
      });
    });
  }

  void handleTap()
  {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ChatPage(
          widget._username,
          AssetImage("assets/logo.png"),
          widget._id),
      ));
  }

  @override
  Widget build(BuildContext context) 
  {
    DateTime time = widget._message ? DateTime.fromMillisecondsSinceEpoch(widget._ref["timestamp"]) : DateTime(0);
    return GestureDetector(
      onTap: () => handleTap(),
          child: Container(
        margin: const EdgeInsets.symmetric(vertical:7),
        width: double.infinity,
        height: 45,
        padding: const EdgeInsets.symmetric(
          horizontal: 10
        ),
        child: Row(
          children: <Widget>[
            Container(
              child: Stack(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage("assets/logo.png"),
                    radius: 24,
                  ),
                  Positioned(
                    bottom: 0.0,
                    right: 0.0,
                    child: Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _online ?  Colors.green : Colors.red
                      ),
                    )
                  )
                ],
              )
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
                        Text(widget._username,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.black)),
                        Text(
                          time.hour.toString() +
                              ":" +
                              (time.minute.toString().length > 1
                                  ? time.minute.toString()
                                  : "0" + time.minute.toString()),
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.grey[600]),
                        ),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(widget._message ? widget._ref["content"] : "",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        ),
                        widget._message && !widget._ref["received"] && widget._ref["from"] != Auth.getUserID()
                            ? Container(
                                height: 15,
                                width: 15,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle, color: Colors.blue),
                              )
                            : Container()
                      ])
                ],
              )),
            ],
          )),
    );
  }
}
