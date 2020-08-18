import 'package:chatapp/pages/Root_page.dart';
import 'package:chatapp/pages/profile_page.dart';
import 'package:chatapp/pages/splash_screen.dart';
import 'package:chatapp/themes/theme.dart';
import 'package:flutter/material.dart';
import 'pages/welcome_page.dart';
import 'services/authentication.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget 
{
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> 
{
  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      routes: {
        'welcome-page': (context) => WelcomePage(new Auth()),
        'root-page': (context) => RootPage(),
        'profile-page': (context) => ProfilePage(),
      },
      theme: theme,
      debugShowCheckedModeBanner: false,
      home: SplashScreen()
    );
  }
}
