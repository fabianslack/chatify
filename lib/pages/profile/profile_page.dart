
import 'package:chatapp/services/authentication.dart';
import 'package:chatapp/services/db_handler.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget 
{
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> 
{

  ScrollController _controller = ScrollController();
  double _opacity = 1.0;
  double _lastOffset = 0.0;
  String username, errorMessage;
  TextStyle style = TextStyle(color: Colors.black);

  @override
  void initState()
  {
    super.initState();
    //_lastOffset = _controller.offset;
    _controller.addListener(() 
    {
      setState(() 
      {
        // up
        if(_lastOffset < _controller.offset)
        {
          _opacity -= _controller.offset*0.0001;
        }
        // down
        else if (_lastOffset > _controller.offset)
        {
          _opacity += _controller.offset*0.0001;
        }
        _lastOffset = _controller.offset;

        print(_opacity);
        if(_opacity < 0 )
        {
          _opacity = 0;
        }
        if(_opacity > 1)
        {
          _opacity = 1;
        }
        });
    });
  }

  void handleLogOut() async
  {
    Auth _auth = Auth();
    _auth.setOnlineStatus(false);
    await _auth.signOut();
    FocusScope.of(context).unfocus();
    Navigator.pushReplacementNamed(context, 'welcome-page');
  }

  validateSub() {
    if(username != null) {
      Db().setUsername(username);
    } else {
      
    }
  }

  showMenu(String cont) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: StatefulBuilder(
            builder: (context, setState) => 
            Container(
              height: 200,
              child: Stack(
                children: [
                  TextField(
                    
                    style: style,
                    decoration: InputDecoration(
                      errorText: errorMessage,
                      enabledBorder: UnderlineInputBorder(      
                        borderSide: BorderSide(color: Colors.black),   
                      ),  
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintStyle: style,
                      hintText: "Enter new " + cont + "...",
                      
                    ),
                    onChanged: (value) => username = value,
                  ),
                  Positioned(
                    child: FloatingActionButton(
                      child: Icon(Icons.check),
                      onPressed: () {
                        if(username != null) {
                          errorMessage = null;
                          setState(() {});
                          Navigator.pop(context);
                          Db().setUsername(username);
                        } else {
                          setState((){
                            errorMessage = "Username can't be empty";
                          });
                        }
                      },
                    ),
                    right: 0,
                    bottom: 0,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget getBody() 
  {
    return RefreshIndicator(
      onRefresh: () {
        setState(() {
          
        });
        return Future.delayed(Duration(milliseconds: 200));
      },
      child: CustomScrollView(
        //controller: _controller,
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            elevation: 0,
            backgroundColor: Colors.white,
            floating: true,
            snap: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: FutureBuilder(
                future: Db().getUsername(),
                builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    return Text(snapshot.data.toString());
                  }
                  return Text("loading...");
                },
              ),
              background: FutureBuilder(
                future: Auth().getProfileImage(),
                builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 32, right: 32),
                          child: CircleAvatar(
                              radius: 100,
                              backgroundImage: NetworkImage(snapshot.data),
                          ),
                        ),
                      ],
                    );
                  }
                  return CircularProgressIndicator();
                },
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
                        borderRadius: BorderRadius.circular(32)
                      ),
                      child: Center(child: Text("Add friend", style: TextStyle(fontSize: 24, fontFamily: "Balsamiq Sans"))),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
                        borderRadius: BorderRadius.circular(32)
                      ),
                      child: Center(child: Text("Join global chat", style: TextStyle(fontSize: 24, fontFamily: "Balsamiq Sans"))),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
                        borderRadius: BorderRadius.circular(32)
                      ),
                      child: Center(child: Text("Add story", style: TextStyle(fontSize: 24, fontFamily: "Balsamiq Sans"))),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
                        borderRadius: BorderRadius.circular(32)
                      ),
                      child: Center(child: Text("Coming soon...", style: TextStyle(fontSize: 24, fontFamily: "Balsamiq Sans"))),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
                        borderRadius: BorderRadius.circular(32)
                      ),
                      child: Center(child: Text("Coming soon...", style: TextStyle(fontSize: 24, fontFamily: "Balsamiq Sans"))),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
                        borderRadius: BorderRadius.circular(32)
                      ),
                      child: Center(child: Text("Coming soon...", style: TextStyle(fontSize: 24, fontFamily: "Balsamiq Sans"))),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () {
                      showMenu('username');
                    },
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
                        borderRadius: BorderRadius.circular(32)
                      ),
                      child: Center(child: Text("Change username", style: TextStyle(fontSize: 24, fontFamily: "Balsamiq Sans"))),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
                        borderRadius: BorderRadius.circular(32)
                      ),
                      child: Center(child: Text("Coming soon...", style: TextStyle(fontSize: 24, fontFamily: "Balsamiq Sans"))),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () {
                      handleLogOut();
                    },
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
                        borderRadius: BorderRadius.circular(32)
                      ),
                      child: Center(child: Text("Logout", style: TextStyle(fontSize: 24, fontFamily: "Balsamiq Sans"))),
                    ),
                  ),
                ),
              ]
            )
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      backgroundColor: Colors.white,
      body: getBody()
    );
  }
}