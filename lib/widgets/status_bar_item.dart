import 'package:flutter/material.dart';

class StatusBarItem extends StatefulWidget {
  // the name of the user
  final String name;

  /// the image of the user
  final MemoryImage image;

  /// story watched or not
  bool watched;

  StatusBarItem(this.name, this.image) {
    watched = false;
  }
  @override
  _StatusBarItemState createState() => _StatusBarItemState();
}

class _StatusBarItemState extends State<StatusBarItem> {
  /// get CircualarAvatar which contains the users profile image
  Widget getCircularAvatar() {
    return CircleAvatar(
      radius: 10,
      backgroundImage: widget.image,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          widget.watched
              ? getCircularAvatar()
              : CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 11,
                  child: getCircularAvatar()),
          SizedBox(height: 5),
          Text(widget.name,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400))
        ],
      ),
    );
  }
}
