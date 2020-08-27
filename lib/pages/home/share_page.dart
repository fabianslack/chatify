import 'package:chatapp/themes/theme.dart';
import 'package:flutter/material.dart';

class SharePage extends StatefulWidget 
{
  @override
  _SharePageState createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> 
{
  	GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.7),
      body: Container(
        height: 100,
        width: double.infinity,
        color: Colors.blueAccent,
      ),
    );
  }
}