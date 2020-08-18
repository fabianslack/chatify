
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/services/authentication.dart';
import 'package:flutter/material.dart';

import 'full_photo.dart';

class ChatImage extends StatelessWidget
{
  bool _left;

  var _ref;

  ChatImage(this._ref)
  {
    _left = _ref["from"] == Auth.getUserID();
  }

  @override
  Widget build(BuildContext context) 
  {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(_ref["timestamp"]);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Row(
        mainAxisAlignment: !_left ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          !_left ? Text(
            time.hour.toString() + ":" + time.hour.toString(),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12
            ),
          ) :Container(),
           FlatButton(
             child: Material(
               child: CachedNetworkImage(
                 placeholder: (context, url) => Container(
                   child: CircularProgressIndicator(
                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                   ),
                   width: 200.0,
                   height: 200.0,
                   padding: EdgeInsets.all(70.0),
                   decoration: BoxDecoration(
                     color: Colors.grey[200],
                     borderRadius: BorderRadius.all(
                       Radius.circular(8.0),
                     ),
                   ),
                 ),
                 errorWidget: (context, url, error) => Material(
                   child: Image.asset(
                     'images/img_not_available.jpeg',
                     width: 200.0,
                     height: 200.0,
                     fit: BoxFit.cover,
                   ),
                   borderRadius: BorderRadius.all(
                     Radius.circular(8.0),
                   ),
                   clipBehavior: Clip.hardEdge,
                 ),
                 imageUrl: _ref["content"],
                 width: 200.0,
                 height: 200.0,
                 fit: BoxFit.cover,
               ),
               borderRadius: BorderRadius.all(Radius.circular(8.0)),
               clipBehavior: Clip.hardEdge,
             ),
             onPressed: () {
               Navigator.push(
                   context, MaterialPageRoute(builder: (context) => FullPhoto(url: _ref("content"))));
             },
           ),
           _left ? Text(
            time.hour.toString() + ":" + time.hour.toString(),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12
            ),
          ) : Container()
        ],
      ),
    );
  }
}