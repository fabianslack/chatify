import 'package:chatapp/pages/home/search_page.dart';
import 'package:chatapp/pages/profile_page.dart';
import 'package:chatapp/pages/usersettings_page.dart';
import 'package:chatapp/services/authentication.dart';
import 'package:chatapp/services/friends_service.dart';
import 'package:chatapp/services/message_service.dart';
import 'package:chatapp/widgets/add_story_widget.dart';
import 'package:chatapp/widgets/chat_preview.dart';
import 'package:chatapp/widgets/status_bar_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Home extends StatefulWidget 
{
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin
{
  Auth _auth;

  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();

  bool _searchPressed = false;

  var _stories;
  
  FriendsService _friendsService;

  @override
  void initState()
  {
    super.initState();
    _friendsService = FriendsService();
    _auth = Auth();
    loadStories();

  }

  void handleLogOut() async
  {
    _auth.setOnlineStatus(false);
    await _auth.signOut();
    FocusScope.of(context).unfocus();
    Navigator.pushReplacementNamed(context, 'welcome-page');
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

  void loadStories()
  {
    setState(() {
      _stories = _friendsService.getStories();
    });
  }

  void navigateToProfile()
  {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, animation2) => ProfilePage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child)
      {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      }, 
      transitionDuration: Duration(milliseconds: 400)
      )
    );
  }

  Widget getStoryRow()
  {
    return Container(
      height: 80,
      child: FutureBuilder(
        future: _stories,
        builder: (context, snapshot)
        {
          if(snapshot.hasData && !snapshot.hasError && snapshot.data.length > 0)
          {
            
            return ListView.builder(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data.length,
              itemBuilder: (context, index)
              {
                if(index == 0)
                {
                  return Row(
                    children: [
                       AddStoryWidget(),
                      StatusBarItem(snapshot.data[index])
                    ],
                  );
                }
                return StatusBarItem(snapshot.data[index]);
              } 
            );
          }
          return Container();
        }
      )
    );
  }

  Widget getSearchBar()
  {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 40, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AnimatedContainer(
            alignment: Alignment.centerLeft,
            curve: Curves.linear,
            duration: Duration(milliseconds: 400),
            padding: EdgeInsets.only(left: 5),
            width: _searchPressed ? MediaQuery.of(context).size.width * 0.8: MediaQuery.of(context).size.width - 30,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10)
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  size: 25,
                  color: Colors.grey[400],
                ),
                SizedBox(width: 2,),
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: "Search",
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 18
                      ),
                    ),
                    onTap: ()
                    {
                      setState(() {
                        _searchPressed = !_searchPressed;
                      });
                    },
                  
                  ),
                )
              ],
            ),
          ),
          AnimatedSize(
            duration: Duration(milliseconds: 400),
            vsync: this,
            child: Container(
              height: _searchPressed ? 20 : 0,
              child: _searchPressed ? Text(
              "Close",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 20
                ),
              ) : Container(),
            )
          )
        ],
      ) 
    );
  }

  Widget getChats()
  {
    return StreamBuilder(
      stream: _friendsService.getStream(),
      builder: (context, snapshot) => snapshot.data != null ? ListView.builder(
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
                snapshot.data["friendsId"][index],
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
      ) : Container(),
    );
  }

  Widget getBody()
  {
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () 
          {
            loadStories();
            return new Future<void>.delayed(Duration(seconds: 1));
          } 
        ),
        SliverList(
            
          delegate: SliverChildBuilderDelegate(
            (context, index)
            {
              return Container(
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20,),
                    getStoryRow(),
                    SizedBox(
                      height: 15,
                    ),
                    getChats(),
                    getLogoutButton(),
                  ],
                ),
              );
            },
            childCount: 1
          ),
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
      preferredSize: Size.fromHeight(180),
      child: Column(
        children: [
          AnimatedContainer(
            height: _searchPressed ? 0 : 100,
            duration: Duration(milliseconds: 400),
            child: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              centerTitle: true,
              title: Text(
                "Chats",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                )
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.supervised_user_circle,
                  color: Colors.grey[600],
                  size: 30
                ),
                onPressed: () => navigateToProfile()
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200]
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: Colors.grey,
                        size: 25
                      ),
                      onPressed: () 
                      {
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
          getSearchBar()
        ],
      )
    );
  }
  
  
  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: appBar(),
      body: getBody(),
      backgroundColor: Colors.white,
    );
  }
}
