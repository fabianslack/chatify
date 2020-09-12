
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget 
{
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> 
{

  ScrollController _controller = ScrollController();
  double _opacity = 1.0;
  double _lastOffset = 0.0;

  @override
  void initState()
  {
    super.initState();
    //_lastOffset = _controller.offset;
    _controller.addListener(() 
    {
      setState(() 
      {
        // up
        if(_lastOffset < _controller.offset)
        {
          _opacity -= _controller.offset*0.0001;
        }
        // down
        else if (_lastOffset > _controller.offset)
        {
          _opacity += _controller.offset*0.0001;
        }
        _lastOffset = _controller.offset;

        print(_opacity);
        if(_opacity < 0 )
        {
          _opacity = 0;
        }
        if(_opacity > 1)
        {
          _opacity = 1;
        }
        });
    });
  }

  Widget getBody()
  {
    return CustomScrollView(
      controller: _controller,
      physics: BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          elevation: 0,
          backgroundColor: Colors.white,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Opacity(
                  opacity: _opacity,
                  child: CircleAvatar(
                   backgroundImage: AssetImage("assets/logo.png"),
                   radius: 30,
                  ),
                ),
                Text("Fabian Slack", style: TextStyle(color: Colors.black)),
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