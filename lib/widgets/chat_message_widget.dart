import 'package:chatapp/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatMessage extends StatefulWidget 
{
  bool _liked;
  bool _left;

  var _ref;

  Function _onDoubleClick;

  ChatMessage(this._ref, this._onDoubleClick)
  {
    _liked = _ref["liked"];
    _left = _ref["from"] == Auth.getUserID();
  }

  @override
  _ChatMessageState createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> with TickerProviderStateMixin
{
  @override
  Widget build(BuildContext context) 
  {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(widget._ref["timestamp"]);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical:5),
      child: Column(
        crossAxisAlignment: widget._left ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: !widget._left ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              GestureDetector(
                onDoubleTap: () 
                {
                  widget._liked = !widget._liked;
                  widget._onDoubleClick(widget._ref["timestamp"], widget._liked);
                  HapticFeedback.vibrate();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width*0.6,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: !widget._left ? 
                      BorderRadius.only(
                        bottomRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)) : 
                      BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                      color: widget._left ? Colors.grey[200] : Colors.grey[400],
                    ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          widget._ref["content"], 
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18
                          ),
                          softWrap: true,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          width: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                time.hour.toString() + ":" + (time.minute.toString().length > 1 ? time.minute.toString() : "0" + time.minute.toString()),
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12
                                ),
                              ),
                              widget._left ? Icon(
                                widget._ref["received"] ? Icons.done_all : Icons.done,
                                size: 18,
                                color: Colors.grey,
                              ) : Container()
                            ],
                          ),
                        )
                      )
                    ],
                  )
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:2, vertical: 2),
            child: AnimatedSize(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              vsync: this,
              child: Icon(
                Icons.favorite, 
                color: Colors.red,
                size: widget._liked ? 20 : 0,),
            ),
          ) 
        ],
      )
    );
  }
}