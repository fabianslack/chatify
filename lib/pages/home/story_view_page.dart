import 'package:chatapp/services/friends_service.dart';
import 'package:chatapp/widgets/full_photo.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

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

  @override
  void initState()
  {
    super.initState();
    init();
    print(widget._id);
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


  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      body: Stack(
        children: [
          _imageRef != null ? 
          PhotoView(
            imageProvider: NetworkImage(_imageRef)
           ) : CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget._username,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black
                      )
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 40,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.camera),
                      onPressed: () {},
                    ),
                    Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left:10),
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white30
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Respond...",
                            hintStyle: TextStyle(
                              color: Colors.grey[600]
                            )
                          ),
                        )
                      ),
                    )
                  ],
                )
              ],
            )
          )
        ],  
      )
    );
  }
}