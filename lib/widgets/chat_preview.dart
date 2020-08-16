
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
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.08,
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24
                      )
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          DateTime.fromMillisecondsSinceEpoch(_timestamp).toString(),
                        
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
                    Text(
                      _lastMessage,
                      style: TextStyle(
                        fontSize: 16
                      )
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