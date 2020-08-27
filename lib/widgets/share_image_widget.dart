

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShareImageWidget extends StatelessWidget 
{
  final Function _callback;

  ShareImageWidget(this._callback);

  @override
  Widget build(BuildContext context) 
  {
    return GestureDetector(
      onTap: () 
      {
        _callback();
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width - 30,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.pink[300],
              Colors.orangeAccent
            ]
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(3, 2),
              blurRadius: 3
            )
          ]
        ),    
        child: Row(
          children: [
            Container(
              height: 70,
              width: 70,
              child: Icon(
                Icons.camera_enhance,
                size: 50,
              )
            ),
            SizedBox(width: 5),
            Container(
              width: 250,
              child: Text(
                "Share an image or video with your friends",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22
                ),
              ),
            )
          ],
        )
      ),
    );
  }
}