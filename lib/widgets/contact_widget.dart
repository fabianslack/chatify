
import 'package:flutter/material.dart';

class ContactWidget extends StatefulWidget 
{
  final String name;
  ContactWidget(this.name);
  @override
  _ContactWidgetState createState() => _ContactWidgetState();
}

class _ContactWidgetState extends State<ContactWidget>
 {
  @override
  Widget build(BuildContext context)
   {
    return Row(
      children: <Widget>[
        CircleAvatar(),
        Text(widget.name, style: TextStyle(color: Colors.white)),

      ],
    );
  }
}