import 'dart:io';

import 'package:chatapp/services/authentication.dart';
import 'package:chatapp/themes/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'home/home.dart';
import 'profile_page.dart';
import 'usersettings_page.dart';

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with WidgetsBindingObserver
{
  final PageController _controller = PageController();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  //final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  int _selectedIndex = 0;
  List<Widget> _bodies;
  Auth _auth;

  @override
  void initState()
  {
    super.initState();
    _auth = new Auth();
    _auth.setOnlineStatus(true);
    WidgetsBinding.instance.addObserver(this);
    _bodies = [Home(),  ProfilePage(), ProfileSettingsPage()];
  }

  @override
  void dispose()
  {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

/*
  void init()
  {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) 
    {
      print('onMessage: $message');
      if(Platform.isAndroid)
      {
        showNotification(message['notification'];
      }
      else
      {
        showNotification(message['aps']['alert']);
      }
    }, 
    onResume: (Map<String, dynamic> message) 
    {
      print('onResume: $message');
      return;
    }, 
    onLaunch: (Map<String, dynamic> message) 
    {
      print('onLaunch: $message');
      return;
    }
    );

    firebaseMessaging.getToken().then((token) 
    {
      print('token: $token');
      Firestore.instance
          .collection('users')
          .document(Auth.getUserID())
          .updateData({'pushToken': token});
      }).catchError((err) {
        
    });
  }
  */

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
          _auth.setOnlineStatus(false);
        

        break;
      }
      case AppLifecycleState.paused:
      {
          _auth.setOnlineStatus(false);

        break;
      }
    }
  }

  Widget getBottomNavigationBar()
  {
    return BottomNavigationBar(
      elevation: 0,
      onTap: (index) {
        _controller.animateToPage(index, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
      },
      currentIndex: _selectedIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.primaryColor,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      items: [Icons.chat, Icons.share, Icons.supervised_user_circle]
          .asMap()
          .map((key, value) => MapEntry(
              key,
              BottomNavigationBarItem(
                  title: Text(''),
                  icon: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                        color: _selectedIndex == key
                            ? Colors.red
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Icon(
                      value,
                      color: Colors.white,
                    ),
                  ))))
          .values
          .toList(),
    );
  }

  Widget getBody() {
    return PageView(
      children: _bodies,
      onPageChanged: (value) {
        setState(() {
          _selectedIndex = value;
        });
      },
      controller: _controller,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
      bottomNavigationBar: getBottomNavigationBar(),
    );
  }
}
