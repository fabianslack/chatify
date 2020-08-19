import 'package:flutter/material.dart';

class StatusBarItem extends StatefulWidget {
  // the name of the user
  final String name;

  /// the image of the user
  final AssetImage image;

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
      radius: 22,
      backgroundImage: widget.image,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal : 5),
      child: Container(
        width: 50,
        child: Column(
          children: <Widget>[
            widget.watched ? getCircularAvatar()
            : Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.red,
                    width: 1
                  )
                ),
                child: getCircularAvatar()
              ),
            Padding(
              padding: const EdgeInsets.only(top:2),
              child: Text(
                widget.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.w600, 
                  color: Colors.black
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}
