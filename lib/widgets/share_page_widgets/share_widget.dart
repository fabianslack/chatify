import 'package:flutter/material.dart';

abstract class ShareWidget extends StatelessWidget 
{
  final Function _callback;

  ShareWidget(this._callback);

  Widget getBody(BuildContext context, Widget child, bool small)
  {
    return GestureDetector(
      onTap: () 
      {
        Navigator.of(context).pop();
        _callback();
      },
      child: Container(
        width:  small ? (MediaQuery.of(context).size.width - 60) / 2 : MediaQuery.of(context).size.width - 40,
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey[400],
              offset: Offset(3, 3),
              blurRadius: 6
            )
          ]
        ),
        child: child,    
      ),
    ); 
  }
}