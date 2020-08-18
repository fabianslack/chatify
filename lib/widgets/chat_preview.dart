import 'package:flutter/material.dart';

class ChatPreview extends StatelessWidget {
  String _username;
  String _lastMessage;
  int _timestamp;
  AssetImage _image;
  bool _read;
  String imageRef;

  ChatPreview(this._username, this._lastMessage, this._timestamp, this._image,
      this._read,
      {this.imageRef});

  @override
  Widget build(BuildContext context) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(_timestamp);
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 7),
        width: double.infinity,
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundImage:
                  imageRef == null ? _image : NetworkImage(imageRef),
              radius: 24,
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
                      Text(_username,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
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
                            color: Colors.grey),
                      ),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(_lastMessage,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ),
                      _read
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
        ));
  }
}
