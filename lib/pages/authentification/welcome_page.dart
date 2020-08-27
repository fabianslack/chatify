import 'dart:math';

import 'package:chatapp/pages/authentification/signin_page.dart';
import 'package:chatapp/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

import 'signup_page.dart';
import 'signup_page.dart';

class WelcomePage extends StatefulWidget {
  final Auth _auth;
  WelcomePage(this._auth);
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _formKey = new GlobalKey<FormState>();

  LiquidController liquidController = new LiquidController();
  double _height;
  double _width;
  int page = 0;
  TextStyle style = TextStyle(fontFamily: "Balsamiq Sans", fontSize: 32);

  List<Widget> pages(double width, double height) {
    return [
      Container(
        width: _width,
        color: Colors.purple,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Image.asset(
              'assets/people_talking.png',
              fit: BoxFit.cover,
            ),
            Column(
              children: <Widget>[
                Text(
                  "Chat with your friends\nin realtime!!!", style: style, textAlign: TextAlign.center,
                )
              ],
            ),
          ],
        ),
      ),
      Container(
        width: _width,
        color: Colors.deepOrange,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Image.asset(
              'assets/apps_location.png',
              fit: BoxFit.cover,
            ),
            Column(
              children: <Widget>[
                Text(
                  "Share data from other apps\nOr your current location", style: style, textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
      Container(
        width: _width,
        color: Colors.greenAccent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Image.asset(
              'assets/on_point.png',
              fit: BoxFit.cover,
            ),
            Column(
              children: <Widget>[
                Text(
                  "Bring it on point!", style: style, textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
      Container(
        width: _width,
        color: Colors.blueAccent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Image.asset(
              'assets/key.png',
              fit: BoxFit.cover,
            ),
            Column(
              children: <Widget>[
                Container(
                  width: _width - 120,
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.red, Colors.purple]), borderRadius: BorderRadius.circular(24)),
                  child: FlatButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInPage(),
                          ));
                    },
                    child: Text(
                      "Login", style: style, textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                ),
                Container(
                  width: _width - 120,
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.red, Colors.purple]), borderRadius: BorderRadius.circular(24)),
                  child: FlatButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignupRootPage(),
                          ));
                    },
                    child: Text(
                      "Register", style: style, textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((page ?? 0) - index).abs(),
      ),
    );
    double zoom = 1.0 + (2.0 - 1.0) * selectedness;
    return new Container(
      width: 25.0,
      child: new Center(
        child: new Material(
          color: Colors.white,
          type: MaterialType.circle,
          child: new Container(
            width: 8.0 * zoom,
            height: 8.0 * zoom,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          LiquidSwipe(
            pages: pages(_width, _height),
            onPageChangeCallback: pageChangeCallback,
            waveType: WaveType.liquidReveal,
            liquidController: liquidController,
            ignoreUserGestureWhileAnimating: true,
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                Expanded(child: SizedBox()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(pages(_width, _height).length, _buildDot),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: FlatButton(
                onPressed: () {
                  liquidController.animateToPage(
                      page: pages(_width, _height).length - 1, duration: 500);
                },
                child: Text("Skip to End"),
                color: Colors.white.withOpacity(0.01),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: FlatButton(
                onPressed: () {
                  liquidController.jumpToPage(
                      page: liquidController.currentPage + 1);
                },
                child: Text("Next"),
                color: Colors.white.withOpacity(0.01),
              ),
            ),
          )
        ],
      ),
    );
  }

  pageChangeCallback(int lpage) {
    setState(() {
      page = lpage;
    });
  }
}
