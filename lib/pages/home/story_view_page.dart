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

  Widget getTopBar()
  {
    return Container(
      color: Color(0xFF303030),
      padding:  const EdgeInsets.fromLTRB(10, 10, 0, 0),
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
                ),
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
              decoration: InputDecoration(
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: "Respond...",
                hintStyle: TextStyle(
                  color: Colors.grey[600]
                )
              ),
            )
          ),
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical:4),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFF303030),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20)
          )
        ),
        child:  _imageRef != null ? Image.network(_imageRef) : CircularProgressIndicator(),
      )
    );
  }


  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragEnd: (drag) => close(),
        child: Column(
          children: [
            getTopBar(),
            getImage(),
            SizedBox(height: 4,),
            getBottomBar(),
            SizedBox(height: 2,)
          ],
        ),
      )
    );
  }
}