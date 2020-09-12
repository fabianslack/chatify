import 'package:chatapp/services/friends_service.dart';
import 'package:flutter/material.dart';

class RequestWidget extends StatelessWidget 
{
  final AssetImage _image;
  final String _id;
  final FriendsService _friendsService = FriendsService();

  RequestWidget(this._image, this._id);

  @override
  Widget build(BuildContext context) 
  {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 70,
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundImage: _image,
            radius: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: FutureBuilder(
              future: FriendsService.getUsernameForId(_id),
              builder: (context, snapshot) => snapshot.data != null ? Text(
                snapshot.data,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                )
              ) : Container(),
            ),
          ),
          Spacer(),
          FlatButton(
            padding: EdgeInsets.all(0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20)
              ),
              width: 80,
              height: 30,
              child: Center(
                child: Text(
                  "Accept", 
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  )
                ),
              ),
            ),
            onPressed: () 
            {
              _friendsService.addFriend(_id);
              _friendsService.removeRequest(_id);
            },
          ),
          FlatButton(
            padding: EdgeInsets.all(0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20)
              ),
              width: 80,
              height: 30,
              child: Center(
                child: Text(
                  "Decline", 
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  )
                ),
              ),
            ),
            onPressed: () => _friendsService.removeRequest(_id),
          ),
          
        ],
      ),    
    );
  }
}