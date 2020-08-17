
import 'package:flutter/material.dart';

class ChatPreview extends StatelessWidget
{
  String _username;
  String _lastMessage;
  int _timestamp;
  AssetImage _image;

  ChatPreview(this._username, this._lastMessage, this._timestamp, this._image);

  @override
  Widget build(BuildContext context) 
  {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(_timestamp);
    return Container(
      width: double.infinity,
      height: 50,
      padding: const EdgeInsets.symmetric(
        horizontal: 20
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundImage: _image,
            radius: 25,
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      _username,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                      )
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          time.hour.toString() + ":" + (time.minute.toString().length > 1 ? time.minute.toString() : "0" + time.minute.toString()),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          ),
                        ),
                        Icon(
                          Icons.navigate_next,
                          color: Colors.grey[400],
                          size: 30,
                        )
                      ],
                    )
                  ]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        _lastMessage,
                        style: TextStyle(
                          fontSize: 16
                        )
                      ),
                    ),
                    Icon(
                      Icons.pin_drop,
                      size: 20,
                      color: Colors.white,
                    )
                  ],
                )
              ],
            )
          ),
        ],
      )
    );      

  }
}