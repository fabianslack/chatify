
import 'dart:io';

import 'package:chatapp/models/chat_model.dart';
import 'package:chatapp/services/authentication.dart';
import 'package:flutter/material.dart';

import 'full_photo.dart';

class ChatImage extends StatelessWidget
{
  bool _left;
  bool _downloaded;
  bool _showRead;

  final ChatModel _ref;

  ChatImage(this._ref, this._downloaded, this._showRead)
  {
    _left = _ref.from() == Auth.getUserID();
  }

    
  String buildTimeStamp()
  {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(_ref.timestamp());
    String minute = time.minute.toString();
    String hour = time.hour.toString();
    return hour + ":" +  (minute.length > 1 ? minute : "0" + minute);
  } 

  @override
  Widget build(BuildContext context) 
  {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: Column(
        crossAxisAlignment: !_left ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          FlatButton(
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.grey[200],
                  width: 1
                )
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                  child: _downloaded ?  Image.file(
                  new File(_ref.content()),
                  fit: BoxFit.cover,

                ) : Image(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                  _ref.content(),
                ))

              )
            ),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => FullPhoto(url: _ref.content())));
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
            child: Text(
              _showRead ? "Seen  " + buildTimeStamp() : buildTimeStamp(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.w600
              )
            ),
          )
        ],
      ),
    );
  }
}