
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
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Column(
              children: [
                CircleAvatar(
                 backgroundImage: AssetImage("assets/logo.png"),
                 radius: 10,
                ),
                Text("Fabian Slack"),
              ]
            )
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index)
            {
              return Container(
                width: double.infinity,
                height: 100,
              );
            },
            childCount: 150
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      backgroundColor: Colors.white,
      body: getBody()
    );
  }
}