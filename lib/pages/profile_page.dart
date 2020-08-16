
import 'package:chatapp/services/chat_loader.dart';
import 'package:chatapp/widgets/request_widget.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget 
{
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> 
{
  Widget getBody()
  {
    return StreamBuilder(
      stream: ChatLoader.getStreamRequests(),
      builder: (context, snapshot) => snapshot.hasData ? ListView.builder(
        itemCount: snapshot.data["requests"].length,
        itemBuilder: (context, index) => RequestWidget(
          AssetImage("assets/logo.png"),
          snapshot.data["requests"][index]
        )
      ) : Container(),
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      body: getBody()
    );
  }
}