

import 'package:chatapp/services/authentication.dart';
import 'package:flutter/material.dart';
import 'home/home.dart';

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with WidgetsBindingObserver
{
  Auth _auth;

  @override
  void initState()
  {
    super.initState();
    _auth = new Auth();
    _auth.setOnlineStatus(true);
    WidgetsBinding.instance.addObserver(this);
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Home(),
    );
  }
}
