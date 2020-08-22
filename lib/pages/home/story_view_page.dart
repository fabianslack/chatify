import 'package:chatapp/services/friends_service.dart';
import 'package:flutter/material.dart';

class StoryViewPage extends StatefulWidget 
{
  final String _id;
  final String _username;

  StoryViewPage(this._id, this._username);
  @override
  _StoryViewPageState createState() => _StoryViewPageState();
}

class _StoryViewPageState extends State<StoryViewPage> 
{
  String _imageRef;
  String _profileImage;
  bool _dragginDown = false;
  double _paddingTop = 30;

  bool _holding = false;

  @override
  void initState()
  {
    super.initState();
    init();
  }

  void init()
  {
    FriendsService.loadStoryImage(widget._id).then((value) 
    {
      setState(() {
        _imageRef = value;
      });
    });
  }



  void close()
  {
    Navigator.of(context).pop();
  }

  void onDrag(DragUpdateDetails drag)
  {
    setState(() {
      _paddingTop += drag.primaryDelta*0.4;
      _dragginDown = drag.primaryDelta > 0;
      if(_paddingTop < 20)
      {
        _paddingTop = 20;
      }
      if(_paddingTop > 300)
      {
        close();
      }
    });
  }

  Widget getTopBar()
  {
    return Padding(
            padding:  EdgeInsets.fromLTRB(10, _paddingTop, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'storyimage' + widget._username,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundImage: _profileImage != null ?  
                          NetworkImage(_profileImage) : 
                          AssetImage("assets/logo.png"),
                      )
                    ),
                    SizedBox(width: 10,),
                    Hero(
                      tag: 'story' + widget._username,
                      child: Text(
                        widget._username,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w400
                        )
                      )
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: close,
                )
              ],
            ),
          );
      
      /*
    return Padding(
      padding: EdgeInsets.only(top:_paddingTop),
      child: Container(
        
        child:
      */    
  }

  Widget getBottomBar()
  {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(left:10),
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white24
              )
            ),
            child: TextField(
              style: TextStyle(
                fontSize: 20
              ),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: "Respond...",
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 20
                )
              ),
            ),
          )
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget getImage()
  {
    return Column(
      children: [
        SizedBox(height: _paddingTop,),
        Expanded(
          child: Container(
            width: double.infinity,
            child:  ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)
              ),
              clipBehavior: Clip.hardEdge,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: _imageRef != null ? Image.network(_imageRef) : Container(),
              )
            )
          )
        ),
        SizedBox(height: 50,)
      ]
    );
  }


  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragEnd: (drag) => _dragginDown ? close() : null,
        onVerticalDragUpdate: (drag) => onDrag(drag),
        onLongPressStart: (start) 
        {
          setState(() {
            _holding = true;
          });
        },
        onLongPressEnd: (end) 
        {
          setState(() {
            _holding = false;
          });
         },
        child: Stack(
          children: [
              getImage(),
              !_holding ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getTopBar(),
                  getBottomBar(),
                ],
              ) : Container()
          ],
        ),
      )
    );
  }
}