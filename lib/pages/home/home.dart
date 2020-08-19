
import 'package:chatapp/pages/home/search_page.dart';
import 'package:chatapp/services/authentication.dart';
import 'package:chatapp/services/friends_service.dart';
import 'package:chatapp/services/message_service.dart';
import 'package:chatapp/widgets/chat_preview.dart';
import 'package:chatapp/widgets/status_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget 
{
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin
{
  TextEditingController _controller = TextEditingController();
  SharedPreferences _preferences;
  Auth _auth;

  bool _searchPressed = false;
  bool _searching = false;
  bool _firstClick = false;

  AnimationController _animationController;
  Animation<Offset> _offset;
  
  FriendsService _friendsService;
  double _width;

  @override
  void initState()
  {
    super.initState();
    print("home");
    _friendsService = FriendsService();
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
    _auth.setOnlineStatus(false);
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

  Widget getStoryRow()
  {
    return Container(
      height: 80,
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal:10),
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (context, index)
        {
          return StatusBarItem("testtestestset", AssetImage("assets/logo.png"));
        }
      ),
    );
  }

  Widget getBorder()
  {
    return Container(
      width: double.infinity,
      height: 1,
      color: Colors.grey[200],
    );
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

  Widget getChats()
  {
    return StreamBuilder(
      stream: _friendsService.getStream(),
      builder: (context, snapshot) => snapshot.data != null ? ListView.separated(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemCount: snapshot.data["friends"].length,
        itemBuilder: (context, index) => StreamBuilder(
          stream: MessageService.getHomeStream(getChatRoomId(snapshot.data["friendsId"][index])),
          builder: (context, chatsnapshot)
          {
            if(chatsnapshot.hasData && chatsnapshot.data.documents.length > 0)
            {
              return ChatPreview(
                snapshot.data["friends"][index], 
                chatsnapshot.data.documents[0],
                true,
                snapshot.data["friendsId"][index]
              ); 

            } 
            return ChatPreview(
              snapshot.data["friends"][index],
              null, 
              false, 
              snapshot.data["friendsId"][index]
            );
          } 
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
    );
  }

  Widget getBody()
  {
    return Column(
      children: <Widget>[
        getStoryRow(),
        getBorder(),
        SizedBox(
          height: 5,
        ),
        getChats(),
        //getLogoutButton(),
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
    _width = MediaQuery.of(context).size.width;
    loadChats();
    return Scaffold(
      appBar: !_searchPressed ? appBar() : getSearchBar(),
      body: getBody(),
      backgroundColor: Colors.white,
    );
  }
}
