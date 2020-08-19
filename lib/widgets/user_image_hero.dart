import 'package:flutter/material.dart';

class UserImageHero extends StatefulWidget {
  final _imgRef;
  UserImageHero(this._imgRef);
  @override
  _UserImageHeroState createState() => _UserImageHeroState();
}

class _UserImageHeroState extends State<UserImageHero> {
  showDialogWithImg(imgRef) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(child: Image.network(imgRef)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Test');
    return showDialogWithImg(widget._imgRef);
  }
}
