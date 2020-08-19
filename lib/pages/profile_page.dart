
import 'package:chatapp/services/friends_service.dart';
import 'package:chatapp/widgets/request_widget.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget 
{
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> 
{
  FriendsService _service;

  @override
  void initState()
  {
    super.initState();
    _service = FriendsService();
  }

  Widget getBody()
  {
    return StreamBuilder(
      stream: _service.getStream(),
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