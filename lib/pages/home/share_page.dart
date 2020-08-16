import 'package:chatapp/themes/theme.dart';
import 'package:flutter/material.dart';

class SharePage extends StatefulWidget 
{
  @override
  _SharePageState createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> 
{
  @override
  Widget build(BuildContext context) 
  {
    return DraggableScrollableSheet(
      maxChildSize: 0.8,
      initialChildSize: 0.7,
      builder: (context, scrollController)
      {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: theme.primaryColor
          ),
          child: ListView(
            controller: scrollController,
            children: <Widget>[
              Text("Was geht")
            ],
          ),
        );
      },
    );
  }
}