
import 'package:chatapp/pages/home/search_page.dart';
import 'package:chatapp/services/authentication.dart';
import 'package:chatapp/services/chat_loader.dart';
import 'package:chatapp/themes/theme.dart';
import 'package:chatapp/widgets/chat_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat.dart';

class Home extends StatefulWidget 
{
  final Auth _auth;
  Home(this._auth);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin
{
  TextEditingController _controller = TextEditingController();
  ChatLoader _chatLoader = ChatLoader();
  SharedPreferences _preferences;


  bool _searchPressed = false;
  bool _searching = false;
  bool _firstClick = false;

  AnimationController _animationController;
  Animation<Offset> _offset;
  

  double _height;
  double _width;

  @override
  void initState()
  {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds:100),
      animationBehavior: AnimationBehavior.preserve
    );

    _offset = Tween<Offset>(end: Offset(
      0, 0
    ), begin: Offset(0, 1)).animate(_animationController);
  }

  Future<void> loadChats() async
  {
    //_chats =  await _chatLoader.getFriends();
    _preferences = await SharedPreferences.getInstance();
  }

  void handleLogOut() async
  {
    await widget._auth.signOut();
    FocusScope.of(context).unfocus();
    Navigator.pushReplacementNamed(context, 'welcome-page');
  }

  void handleSearch(String value) async
  {
    setState(() 
    {
      _searching = value.length > 0;
    });
                  
  }

  String getChatRoomId(String id)
  {
    if(id.hashCode >= Auth.getUserID().hashCode)
    {
      return '' + (id.hashCode - Auth.getUserID().hashCode).toString();
    }
    else
    {
      return '' + (Auth.getUserID().hashCode - id.hashCode).toString();

    }
  }

  Widget getSearchBar()
  {
    return PreferredSize(
      preferredSize: Size.fromHeight(100),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 35, 10, 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [ 
            Container(
              width: _width*0.8,
              height: _height * 0.05,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white
              ),
              child: TextField(
                autofocus: true,
                onChanged: handleSearch,
                controller: _controller,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[900],),
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),  
            ),
            GestureDetector(
              child: Text(
                "Close",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                )
              ),
              onTap: ()
              {
                setState(() 
                {
                  _searchPressed = !_searchPressed;
                  _animationController.reverse();
                });
                loadChats();
                _controller.clear();
                FocusScope.of(context).unfocus();
              },
            )
          ]
        ),
      ),
    );
  }

  Widget getBody()
  {
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(top: 40),
          width: _width,
          height: _height,
          decoration: BoxDecoration(
            color: theme.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40)
            )
          ),
          child: StreamBuilder(
            stream: _chatLoader.getStream(),
            builder: (context, snapshot) => snapshot.data != null ? ListView.separated(
              physics: BouncingScrollPhysics(),

              itemCount: snapshot.data["friends"].length,
              itemBuilder: (context, index) => GestureDetector(
                child: StreamBuilder(
                  stream: Firestore.instance.collection("chats").
                    document(getChatRoomId(snapshot.data["friendsId"][index])).
                    collection("messages").
                    orderBy("timestamp", descending: true).
                    limit(1).
                    snapshots(),
                builder: (context, chatsnapshot) =>  !chatsnapshot.hasError && chatsnapshot.hasData && chatsnapshot.data.documents.length > 0? 
                  ChatPreview(
                    snapshot.data["friends"][index], 
                    chatsnapshot.data.documents[0]["content"], 
                    chatsnapshot.data.documents[0]["timestamp"], 
                    AssetImage("assets/logo.png")
                  ) 
                    : 
                  ChatPreview(
                    snapshot.data["friends"][index],
                    "",
                    0,
                    AssetImage("assets/logo.png")
                  ),
                ),
                onTap: () 
                {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChatPage(
                      snapshot.data["friends"][index],
                       AssetImage("assets/logo.png"),
                      snapshot.data["friendsId"][index]),
                  ));
                }
              ),
              separatorBuilder: (BuildContext context, int index) 
              { 
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                  child: Divider(
                  color: Colors.grey[600],
                  thickness: 1,
                  )
                );
              },
            ) : Container(),
          )
        ),
        getLogoutButton(),
        SlideTransition(
          position: _offset,
          child: _firstClick ? SearchPage(_searching, _controller.text.trim(), _preferences) : null,
        ),
      ],
    );
  }
  
  Widget getLogoutButton() 
  {
    return FlatButton(
      color: Colors.blue,
      child: Text("logout"),
      onPressed: handleLogOut,
    );
  }

  Widget appBar()
  {
    return PreferredSize(
      preferredSize: Size.fromHeight(_height*0.1),
      child: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Messages",
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold
          )
        ),
        leading: IconButton(
          icon: Icon(
            Icons.add,
            color: Colors.white,
            size: 30
          ),
          onPressed: () 
          {
            
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
              size: 30
            ),
            onPressed: () 
            {
              setState(() {
                _searchPressed = true;
                _searching = false;
                _firstClick = true;
                _animationController.forward();
              });
            },
          )
        ],
      ),
    );
  }
  
  
  @override
  Widget build(BuildContext context) 
  {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    loadChats();
    return Scaffold(
      appBar: !_searchPressed ? appBar() : getSearchBar(),
      body: getBody()
    );
  }
}
