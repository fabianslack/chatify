import 'package:chatapp/services/chat_loader.dart';
import 'package:flutter/material.dart';

class RequestWidget extends StatelessWidget 
{
  AssetImage _image;
  final String _id;
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
              future: ChatLoader.getUsernameForUID(_id),
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
              ChatLoader.addFriend(_id);
              ChatLoader.removeRequest(_id);
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
            onPressed: () => ChatLoader.removeRequest(_id),
          ),
          
        ],
      ),    
    );
  }
}