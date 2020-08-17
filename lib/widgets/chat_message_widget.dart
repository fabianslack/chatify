import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget 
{
  final String _message;
  final bool _left;
  final int _timestamp;
  final bool _received;

  ChatMessage(this._message,this._left, this._timestamp, this._received);

  @override
  Widget build(BuildContext context) 
  {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(_timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical:5),
      child: Row(
        mainAxisAlignment: !_left ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          Container(
            width: MediaQuery.of(context).size.width*0.6,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: !_left ? BorderRadius.only(
                bottomRight: Radius.circular(20),
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20)) : 
              BorderRadius.only(
                bottomLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20)),
              color: _left ? Colors.grey[200] : Colors.grey[400],
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    _message, 
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
                        _left ? Icon(
                          _received ? Icons.done_all : Icons.done,
                          size: 18,
                          color: Colors.grey,
                        ) : Container()
                      ],
                    ),
                  )
                )
              ],
            )
          )
        ],
      ),
    );
  }
}