import 'package:chatapp/pages/home/search_page.dart';
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
    return Container(
      padding: const EdgeInsets.only(left: 5),
      width: MediaQuery.of(context).size.width - 30,
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
              readOnly: true,
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
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (c, a1, a2) => SearchPage(),
                  transitionsBuilder: (c, anim1, a2, child) => FadeTransition(
                    opacity: anim1, 
                    child: child,
                  ),
                  transitionDuration: Duration(milliseconds: 500),
                )); 
              },
             
            ),
          )
        ],
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
                    SizedBox(height: 10),
                    getSearchBar(),
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
    return AppBar(
      elevation: 1,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        "Chats",
        style: TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold
        )
      ),
      leading: IconButton(
        icon: Icon(
          Icons.supervised_user_circle,
          color: Colors.grey[600],
          size: 30
        ),
        onPressed: () 
        {
          
        },
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
