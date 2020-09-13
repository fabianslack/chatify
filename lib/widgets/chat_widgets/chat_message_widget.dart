import 'dart:ui';

import 'package:chatapp/models/chat_model.dart';
import 'package:chatapp/services/authentication.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatefulWidget 
{

  final ChatModel _ref;

  final bool _showIsOwn;

  ChatMessage(this._ref, this._showIsOwn);

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
   // _received = widget._ref.received() && widget._ref.from() == Auth.getUserID();
    _received = widget._ref.read() && widget._ref.from() == Auth.getUserID();
   //_received = false;
  }
  
  String buildTimeStamp()
  {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(widget._ref.timestamp());
    String minute = time.minute.toString();
    String hour = time.hour.toString();
    return hour + ":" +  (minute.length > 1 ? minute : "0" + minute);
  } 

  Widget getChatContainer()
  {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: _right ? Color(0xff0079ff) : Color(0xffeeeeee),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal:12),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: widget._ref.content(),
                    style: TextStyle(
                      color: _right ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400
                    ),
                  ),
                  TextSpan(
                    text: buildTimeStamp() + "  ",
                    style: TextStyle(
                      color: Colors.transparent
                    )
                  )
                ]
              ),
            ) 
          ),
          Positioned(
            child: Row(
              children: [
                Text(
                  buildTimeStamp(),
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w500,
                    color: _right ? Colors.white : Colors.black
                  ),
                ),
                Icon(
                  _received && widget._ref.from() == Auth.getUserID() ?  Icons.done_all : Icons.done,
                  color: _right ? Colors.white : Colors.black,
                  size: 14,
                )
              ],
            ),
            right: 8.0,
            bottom: 6.0,
           )
        ],
      )
    );
  }


  @override
  Widget build(BuildContext context) 
  {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(14, 2, 14, 1),
          child: Row(
            mainAxisAlignment: !_right ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  widget._showIsOwn ? CustomPaint(
                    painter: CustomChatBubble(isOwn: _right),
                    child: getChatContainer(),
                  ) :
                  getChatContainer(),
                ],
              ),
             
            ],
          ),
        )
      ],
    );
  }

}

class CustomChatBubble extends CustomPainter {
  CustomChatBubble({ @required this.isOwn});

  final bool isOwn;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = isOwn ? Color(0xff0079ff): Color(0xffeeeeee);

    Path paintBubbleTail() {
      Path path;
      if (!isOwn) {
        path = Path()
          ..moveTo(6, size.height -5)
          ..quadraticBezierTo(-5, size.height, -7, size.height - 2) 
          ..quadraticBezierTo(-2, size.height - 5, 0, size.height - 14);
      }
      if (isOwn) {
        path = Path()
          ..moveTo(size.width - 6, size.height - 4)
          ..quadraticBezierTo(
              size.width + 5, size.height, size.width + 7, size.height - 2)
          ..quadraticBezierTo(
              size.width + 2, size.height - 5, size.width, size.height - 14);
      }
      return path;
    }

    final RRect bubbleBody = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(18));
    final Path bubbleTail = paintBubbleTail();

    canvas.drawRRect(bubbleBody, paint);
    canvas.drawPath(bubbleTail, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) 
  {
    return true;
  }
}