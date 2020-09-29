
import 'dart:async';
import 'package:chatapp/models/friend_model.dart';
import 'package:chatapp/pages/home/chat.dart';
import 'package:chatapp/services/friends_service.dart';
import 'package:chatapp/services/message_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatPreview extends StatefulWidget 
{
  final String _id;

  ChatPreview(this._id);

  @override
  _ChatPreviewState createState() => _ChatPreviewState();
}

class _ChatPreviewState extends State<ChatPreview> 
{
  String _imageRef;
  bool _read;
  String _username;

  @override
  void initState() 
  {
    super.initState();
   
  }

  void loadProfileImage() 
  {
    FriendsService.loadImage(widget._id).then((value) 
    {
      setState(() {
        _imageRef = value;
      });
    });
  }

  void loadUsername()
  {
    FriendsService.getUsernameForId(widget._id).then((value)
    {
      setState(() {
        _username = value;
      });
    });
  }

  void handleTap() 
  {
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (context) => ChatPage(_username, _imageRef, widget._id),
    ));
  }

  void handleLongTap()
  {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30)
      ),
      context: context,
      builder: (context)
      {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
         // child: SharePage(widget._id),
        );
      }
    );
  }

  Widget getImage()
  {
    return Container(
      height: 55,
      width: 55,
      child: Stack(
        children: [
          CircleAvatar(
            backgroundImage: _imageRef != null ? NetworkImage(_imageRef) : AssetImage("assets/logo.png"),
            radius: 28,
          ),
          StreamBuilder(
            stream: MessageService.getOnlineStatus(widget._id),
            builder: (context, snapshot)
            {
              if(snapshot.hasData)
              {
                return snapshot.data["online"] ? Positioned(
                  bottom: 0.0,
                  right: 0.0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white
                    ),
                    child: Center(
                      child: Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green
                        )
                      ),
                    ),
                  )
                ) : Container();
              }
              return Container();
            }
          ) 
        ],
      ),
    );
  }

  Widget getNewMessageAlert()
  {
    return Container(
      height: 15,
      width: 15,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue
      ),
    );
  }

  Widget getContent()
  {
  //  _read = widget._message ? widget._ref["received"] && widget._ref["from"] != Auth.getUserID() : false;
    _read = true;

    
    return Row(
      children: <Widget>[
        getImage(),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: StreamBuilder(
            stream: MessageService.getHomeStream(widget._id),
            builder: (context, snapshot)
            {
              if(snapshot.data != null)
              {
                var ref = snapshot.data.documents[0];
                DateTime time = snapshot.data != null 
                ? DateTime.fromMillisecondsSinceEpoch(ref["timestamp"])
                : DateTime(0);
                String _time = time.hour.toString() + ":" + (time.minute.toString().length > 1 ? time.minute.toString() : "0" + time.minute.toString());

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_username != null ? _username : "",
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Colors.black
                          )
                        ),
                        Text(
                          _time,
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                            fontSize: 14
                          )
                        ),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ref["content"] != null ? ref["type"] == 0 ? ref["content"] : "Image" : "",
                          overflow: TextOverflow.ellipsis,
                          style:  TextStyle(
                            fontSize: 16, 
                            fontWeight: !_read ? FontWeight.normal :  FontWeight.w600,
                            color: !_read ? Colors.grey : Colors.black
                          )
                        ),
                        _read && snapshot.data.documents[0]["content"] != null ? getNewMessageAlert() : Container()
                      ] ,
                    )
                  ],
                );
              }
              return Container();
            }
          )
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    loadProfileImage();
    loadUsername();
    return Padding(
      padding: const EdgeInsets.only(right:10.0),
      child: GestureDetector(
        onTap: () => handleTap(),
        onLongPress: () => handleLongTap(),
        child: Container(
          width: double.infinity,
          color: Colors.white,
          height: 75,
          child: getContent()
          ),
      ),
    );
  }
}
