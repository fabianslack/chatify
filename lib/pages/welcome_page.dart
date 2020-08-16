
import 'package:chatapp/pages/authentification/signin_page.dart';
import 'package:chatapp/services/authentication.dart';
import 'package:flutter/material.dart';

import 'authentification/signup_page.dart';
import 'home/home.dart';

class WelcomePage extends StatefulWidget {
  final Auth _auth;
  WelcomePage(this._auth);
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _formKey = new GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  double _height;
  double _width;

  bool validateAndSave() {
    final form = _formKey.currentState;

    setState(() {
    });

    if (form.validate()) {
      return true;
    }
    return false;
  }

  Widget getFirstPage()
  {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Form(
        child: ListView(
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            SizedBox(
              height: 0.3*_height,
            ),
            Image(
              image: AssetImage(
                "assets/logo.png",
              ),
            ),
            SizedBox(
              height: 100,
            ),
            FlatButton(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white
                ),
                height: _height*0.1,
                width: _width*0.8,
                child: Center(
                  child: Text(
                    "Logn"
                  ),
                )
              ),
              onPressed: () 
              {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => SignInPage(),
                ));
              },
            ),
            SizedBox(
              height: 30,
            ),
            FlatButton(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black
                ),
                height: _height*0.1,
                width: _width*0.8,
                child: Center(
                  child: Text(
                    "Sign up"
                  ),
                ),
              ),
              onPressed: () 
              {
                Navigator.push(context, MaterialPageRoute(
                   builder: (context) => SignupRootPage()
                ));
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return getFirstPage();
  }
}
