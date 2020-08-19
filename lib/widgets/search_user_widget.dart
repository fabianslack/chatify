
import 'package:chatapp/services/friends_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchUserWidget extends StatefulWidget 
{
  final String _username;
  final AssetImage _image;
  bool _added;
  final String id;
  SearchUserWidget(this._username, this._image, this._added, this.id);
  @override
  _SearchUserWidgetState createState() => _SearchUserWidgetState();
}

class _SearchUserWidgetState extends State<SearchUserWidget> 
{
  double height;
  double width;

  FriendsService _service;

  bool _story = true;

  static List<String> _recentSearches;

  _SearchUserWidgetState()
  {
    _service = FriendsService();
    if(_recentSearches == null)
    {
      _recentSearches = List();
    }
  }

  void handleClickAdd() async
  {
    setState(() 
    {
      widget._added = !widget._added;
    });
    if(_recentSearches.length > 7)
    {
      _recentSearches.removeAt(0);
    }
    if(!_recentSearches.contains(widget._username))
    {
      _recentSearches.add(widget._username);
    }
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setStringList("recentSearches", _recentSearches);
    _service.addRequest(widget.id);
    
  }

  void handleClickChat()
  {

  }

  @override
  Widget build(BuildContext context)
  {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      height: height*0.1,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
                   Center(
            child: CircleAvatar(
              backgroundColor: _story ? Colors.red : Colors.grey[300],
              radius: 20,
              child: CircleAvatar(
                backgroundImage: widget._image,
                radius: 18,
              ),
            ),
          ),
          Text(
            widget._username,
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(
            //width: width*0.45,
          ),
         GestureDetector(
            onTap: ()
            {
              !widget._added ? handleClickAdd() : handleClickChat();
            },
            child: Container(
              height: MediaQuery.of(context).size.height * 0.04,
              width: MediaQuery.of(context).size.width * 0.2,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      widget._added ? "Chat" : "Add",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    Icon(
                      widget._added ? Icons.chat : Icons.group_add,
                      color: Colors.black,
                      size: 20,
                    ),
                    ]
                )
              ),
            ),
         )
        ],
      ),
    );
  }
}