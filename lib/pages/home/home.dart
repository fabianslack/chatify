import 'package:chatapp/pages/profile/profile_page.dart';
import 'package:chatapp/services/authentication.dart';
import 'package:chatapp/services/friends_service.dart';
import 'package:chatapp/services/message_service.dart';
import 'package:chatapp/widgets/story_wigets/add_story_widget.dart';
import 'package:chatapp/widgets/chat_widgets/chat_preview.dart';
import 'package:chatapp/widgets/story_wigets/status_bar_item.dart';
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
  final GlobalKey _searchHeightKey = GlobalKey();

  bool _searchPressed = false;
  // is searchBar in show or not
  bool _searchBarCollapsed = false;
  // when the user scrolls up or down, this boolean is changed
  // used for determining whether Search-Icon and Textfield should be shown or not
  bool _searchBarSizeChange = false;


  var _stories;
  String _profileImage;
  
  FriendsService _friendsService;
  TextEditingController _textController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  int _animationDuration = 250;

  @override
  void initState()
  {
    super.initState();
    _friendsService = FriendsService();
    _auth = Auth();
    loadStories();
    getProfileImage();
    _scrollController.addListener(onScrollUpdate);

  }

  void onScrollUpdate()
  {
    RenderBox box = _searchHeightKey.currentContext.findRenderObject();
    Size size = box.size;

    if(size.height == 0)
    {
      setState(() {
        _searchBarCollapsed = true;
      });
    }

    if(size.height > 0 && _searchBarCollapsed)
    {
      setState(() {
        _searchBarCollapsed = false;
      });
    }

    if(size.height < 30)
    {
      setState(() {
        _searchBarSizeChange = true;
      });
    }

    if(size.height >= 30&& _searchBarSizeChange)
    {
      setState(() {
        _searchBarSizeChange = false;
      });
    }
  }

  void getProfileImage()
  {
    FriendsService.loadImage(Auth.getUserID()).then((value) 
    {
      setState(() {
        _profileImage = value;
      });
    });
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
    return Flexible(
      fit: FlexFit.tight,
      key: _searchHeightKey,
      child: _searchBarCollapsed ? Container() : Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AnimatedContainer(
              alignment: Alignment.centerLeft,
              curve: Curves.linear,
              duration: Duration(milliseconds: _animationDuration),
              padding: EdgeInsets.only(left: 5),
              width: _searchPressed ? MediaQuery.of(context).size.width * 0.8: MediaQuery.of(context).size.width-20,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10)
              ),
              child:  _searchBarSizeChange ? Container() : Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 25,
                    color: Colors.grey[400],
                  ) ,
                  SizedBox(width: 2,),
                  Expanded(
                    child: TextField(
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      controller: _textController,
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
                          _searchPressed = true;
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
            AnimatedSize(
              duration: Duration(milliseconds: _animationDuration),
              vsync: this,
              child: GestureDetector(
                onTap: ()
                {
                  setState(() {
                    _searchPressed = !_searchPressed;
                  });
                  FocusScope.of(context).unfocus();
                  _textController.clear();
                },
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
                ),
              )
            )
          ],
        ),
      ),
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
      controller: _scrollController,
      physics: BouncingScrollPhysics(),
      slivers: [
        appBar(),
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
                padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20,),
                    getStoryRow(),
                    SizedBox(height: 10,),
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
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      expandedHeight: 100,
      flexibleSpace: Column(
        children: [
          AnimatedContainer(
            height: _searchPressed ? 0 : 80,
            duration: Duration(milliseconds: _animationDuration),
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
              bottom: _searchBarCollapsed ?  PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Container(
                  height: 1,
                  width: double.infinity,
                  color: Colors.grey[200],
                ),
              ) : null,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => navigateToProfile(),
                  child: CircleAvatar(
                    backgroundImage: _profileImage != null ? NetworkImage(
                      _profileImage
                    ) : AssetImage("assets/logo.png"),
                  )
                ),
              ),
              actions: <Widget>[
                IconButton(
                  splashRadius: 20,
                  icon: Icon(
                    Icons.add,
                    color: Colors.blue,
                    size: 30
                  ),
                  onPressed: () 
                  {
                  },
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
      body: getBody(),
      backgroundColor: Colors.white,
    );
  }
}
