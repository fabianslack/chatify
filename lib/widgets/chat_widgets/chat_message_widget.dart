import 'package:chatapp/models/chat_model.dart';
import 'package:chatapp/services/authentication.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatefulWidget 
{

  final int _index;

  final ChatModel _ref;

  final bool _showImage;

  final String _profileImage;

  final bool _showTime;

  ChatMessage(this._ref, this._index, this._showImage, this._profileImage, this._showTime);

  @override
  _ChatMessageState createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> with TickerProviderStateMixin
{
  bool _right;
  bool _received;

  @override
  void initState()
  {
    super.initState();
    _right = widget._ref.from() == Auth.getUserID();
    _received = widget._ref.received();
  }



  Widget getChatContainer()
  {
    return Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.7),
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
        decoration: BoxDecoration(
    borderRadius:BorderRadius.circular(20),
      color: _right ? Color(0xff0079ff) : Color(0xffeeeeee),
    ),
    child: Text(
      widget._ref.type() == 0 ? widget._ref.content() : "Image", 
      style: TextStyle(
        color: _right ? Colors.white : Colors.black,
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

  Widget getTimeText()
  {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(widget._ref.timestamp());
    String minute = time.minute.toString();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          time.hour.toString() + ":" + (minute.length < 2 ? "0" + minute : minute),
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    return Column(
      children: [
        widget._showTime ? getTimeText() : Container(),
        widget._showTime ? SizedBox(height: 10,) : Container(),
        Padding(
          padding: EdgeInsets.fromLTRB(widget._showImage ? 0 : 36, 1, 8, 1),
          child: Row(
            mainAxisAlignment: !_right ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              widget._showImage ? Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 4, 0),
                child: CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(
                    widget._profileImage
                  )
                ),
              ) : Container(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  getChatContainer(),
                  _received && widget._index == 0 && widget._ref.from() == Auth.getUserID() ? getReadText() : Container() 
                ],
              )
              
            ],
          ),
        )
      ],
    );
  }
}