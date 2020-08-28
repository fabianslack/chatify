import 'package:flutter/material.dart';

abstract class ShareWidget extends StatelessWidget 
{
  final Function _callback;

  ShareWidget(this._callback);

  Widget getBody(String text, BuildContext context, Color color1, Color color2, IconData icon)
  {
    return GestureDetector(
      onTap: () 
      {
        Navigator.of(context).pop();
        _callback();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width - 30,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              color1,
              color2
            ]
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(3, 2),
              blurRadius: 4
            )
          ]
        ),    
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 70,
              width: 70,
              child: Icon(
                icon,
                size: 60,
              )
            ),
            SizedBox(width: 5),
            Container(
              width: 250,
              child: Text(
                text,
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