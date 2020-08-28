import 'package:chatapp/services/authentication.dart';
import 'package:chatapp/services/friends_service.dart';
import 'package:flutter/material.dart';

class AddStoryWidget extends StatefulWidget 
{
  @override
  _AddStoryWidgetState createState() => _AddStoryWidgetState();
}

class _AddStoryWidgetState extends State<AddStoryWidget> {
  String _pofileImageRef;

  @override
  void initState()
  {
    super.initState();
    init();
  }

  void init()
  {
    FriendsService.loadImage(Auth.getUserID()).then((value)
    {
      setState(() {
        _pofileImageRef = value;
        print(_pofileImageRef);
      });
    });
  }

  Widget getProfileImage()
  {
    return GestureDetector(
      onTap: () 
      {
      },
      child: _pofileImageRef != null ? CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(
          _pofileImageRef
        )
      ) : Container(),
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        width: 65,
        child: Column(
          children: <Widget>[
            Container(
              height: 56,
              width: 56,
              child: Stack(
                children: [
                  getProfileImage(),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 7,),
            Text(
              "Add story",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.w600, 
                color: Colors.black
              )
            )
          ],
        ),
      ),
    );
  }
}