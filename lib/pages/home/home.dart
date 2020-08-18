
import 'package:chatapp/pages/home/search_page.dart';
import 'package:chatapp/services/authentication.dart';
import 'package:chatapp/services/chat_loader.dart';
import 'package:chatapp/widgets/chat_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat.dart';

class Home extends StatefulWidget 
{
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin
{
  TextEditingController _controller = TextEditingController();
  ChatLoader _chatLoader = ChatLoader();
  SharedPreferences _preferences;
  Auth _auth;

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
    _auth = Auth();
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
    _preferences = await SharedPreferences.getInstance();
  }

  void handleLogOut() async
  {
    await _auth.signOut();
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

  void handleTap(String username, String userid)
  {
     Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ChatPage(
          username,
          AssetImage("assets/logo.png"),
          userid),
      ));
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
        padding: const EdgeInsets.fromLTRB(10, 35, 10, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [ 
            Container(
              width: _width*0.8,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.grey[200]
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
                  contentPadding: const EdgeInsets.only(bottom: 10),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[900],
                    size:30),
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
                  fontSize: 18,
                  color: Colors.black,
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
    return Padding(
      padding: const EdgeInsets.only(top:20),
      child: Stack(
        children: <Widget>[
          StreamBuilder(
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
                builder: (context, chatsnapshot) =>  !chatsnapshot.hasError && chatsnapshot.hasData && chatsnapshot.data.documents.length > 0 ? 
                  ChatPreview(
                    snapshot.data["friends"][index], 
                    chatsnapshot.data.documents[0]["content"], 
                    chatsnapshot.data.documents[0]["timestamp"], 
                    AssetImage("assets/logo.png"),
                    !chatsnapshot.data.documents[0]["received"] && chatsnapshot.data.documents[0]["from"] != Auth.getUserID(),
                  ) 
                    : 
                  ChatPreview(
                    snapshot.data["friends"][index],
                    "",
                    0,
                    AssetImage("assets/logo.png"),
                    false
                  ),
                ),
                onTap: () => handleTap(snapshot.data["friends"][index], snapshot.data["friendsId"][index])
              ),
              separatorBuilder: (context, index)
              {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(65, 0, 10, 0),
                  child: Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.grey[200],
                  ),
                );
              },
            ) : Container(),
          ),
          //getLogoutButton(),
          SlideTransition(
            position: _offset,
            child: _firstClick ? SearchPage(_searching, _controller.text.trim(), _preferences) : null,
          ),
        ],
      ),
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
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        "Messages",
        style: TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.w700
        )
      ),
      leading: IconButton(
        icon: Icon(
          Icons.add,
          color: Colors.grey,
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
            color: Colors.grey,
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
      body: getBody(),
      backgroundColor: Colors.white,
    );
  }
}
