import 'package:chatapp/services/authentication.dart';
import 'package:chatapp/themes/theme.dart';
import 'package:flutter/material.dart';
import 'home/home.dart';
import 'profile_page.dart';
import 'story_page.dart';

class RootPage extends StatefulWidget
{
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with WidgetsBindingObserver
{
  final PageController _controller = PageController();
  int _selectedIndex = 0;
  Home _home;
  ProfilePage _profilePage;
  StoryPage _storyPage;
  List<Widget> _bodies;
  Auth _auth;

  @override
  void initState()
  {
    super.initState();
    _auth = new Auth();
    WidgetsBinding.instance.addObserver(this);
    _home = Home();
    _profilePage = ProfilePage();
    _storyPage = StoryPage();
    _bodies = [
      _home, 
      _profilePage,
      _storyPage
    ];

  }

  @override
  void dispose()
  {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch(state)
    {
      case AppLifecycleState.resumed:
      {
        _auth.setOnlineStatus(true);
        break;
      }
      case AppLifecycleState.detached:
      {
        break;      
      }
      case AppLifecycleState.inactive:
      {
        Future.delayed(Duration(minutes: 1), ()
        {
          _auth.setOnlineStatus(false);
        });

        break;
      }
      case AppLifecycleState.paused:
      {
        Future.delayed(Duration(minutes: 1), ()
        {
          _auth.setOnlineStatus(false);
        });
        break;
      }
    }
  }

  Widget getBottomNavigationBar()
  {
    return BottomNavigationBar(
      elevation: 0,
      onTap: (index) 
      {
        _controller.jumpToPage(index);
      },
      currentIndex: _selectedIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.primaryColor,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      items: [Icons.chat, Icons.search, Icons.share, Icons.supervised_user_circle]
          .asMap()
          .map((key, value) => MapEntry(
          key, BottomNavigationBarItem(
          title: Text(''),
          icon: Container(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
            decoration: BoxDecoration(
                color: _selectedIndex == key
                    ? Colors.red
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20.0)
            ),
            child: Icon(value, color: Colors.white,),
          )
      )
      )
      ).values.toList(),
    );
  }

  Widget getBody() 
  {
   return PageView(
     children: _bodies,
     onPageChanged: (value)
     {
       setState(() 
       {
          _selectedIndex = value;  
       });
     },
     controller: _controller,
   ); 
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(body: getBody(), bottomNavigationBar: getBottomNavigationBar(),);
  }
}