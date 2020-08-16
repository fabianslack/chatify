
import 'package:chatapp/services/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget 
{
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
{

  void handleStartup() async
  {
    Auth _auth = Auth();

    FirebaseUser user = await _auth.getCurrentUser();
    print(user);
    if(user != null)
    {
      Auth.setUserID(user.uid);
      Navigator.of(context).pushReplacementNamed("root-page");
    }
    else
    {
      Navigator.of(context).pushReplacementNamed("welcome-page");
    }
  }

  @override 
  void initState()
  {
    super.initState();
    handleStartup();
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
     
    );
  }
}