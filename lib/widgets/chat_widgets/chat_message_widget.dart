import 'package:chatapp/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatMessage extends StatefulWidget 
{
  bool _liked;
  bool _right;

  int _index;

  var _ref;

  Function _onDoubleClick;

  ChatMessage(this._ref, this._onDoubleClick, this._index)
  {
    _liked = _ref["liked"];
    _right = _ref["from"] == Auth.getUserID();
  }

  @override
  _ChatMessageState createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> with TickerProviderStateMixin
{

  Widget getChatContainer()
  {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(widget._ref["timestamp"]);

    return  Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.7),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius:BorderRadius.circular(20),
          color: widget._right ? Color(0xff0079ff) : Color(0xffeeeeee),
        ),
        child: Text(
          widget._ref["type"] == 0 ? widget._ref["content"] : "Image", 
          style: TextStyle(
            color: widget._right ? Colors.white : Colors.black,
            fontSize: 18
          ),
          softWrap: true,
        ),
    );
  }

  Widget getReadText()
  {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 5, 2),
      child: Text(
        "Read",
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
          fontWeight: FontWeight.w500
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical:1),
      child: Column(
        crossAxisAlignment: widget._right ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: !widget._right ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onDoubleTap: () 
                    {
                      widget._liked = !widget._liked;
                      widget._onDoubleClick(widget._ref["timestamp"], widget._liked);
                      HapticFeedback.vibrate();
                    },
                    child: getChatContainer()
                  ),
                  widget._ref["received"] && widget._index == 0 && widget._ref["from"] == Auth.getUserID() ? getReadText() : Container() 
                ],
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