
import 'dart:async';
import 'package:chatapp/services/authentication.dart';
import 'package:flutter/material.dart';

enum Login
{
  USERNAME, EMAIL, PASSWORD
}

class SignupRootPage extends StatefulWidget 
{
  @override
  _SignupRootPageState createState() => _SignupRootPageState();
}

class _SignupRootPageState extends State<SignupRootPage> 
{
  final TextEditingController _controller = TextEditingController();
  
  Login _type = Login.USERNAME;
  Auth _auth = new Auth();
  /// set the state of the button 
  /// state 1 = stanard representation
  /// state 2 = circularProgressIndicator
  /// state 3 = finished Icon
  int _buttonState = 0;

  bool _firstTap = true;

  /// stores the height of the screen
  double height;

  /// stores the width of the screen
  double width;

  /// holds the username 
  String _username;
  /// holds the password
  String _password;
  /// holds the email address
  String _email;

  String _errorMessage;

  /// determines whether the keyboard is shown
  bool _keyBoardVisible()
  {
    return (MediaQuery.of(context).viewInsets.bottom == 0);
  }

  /// if the email widget is the currently show widget, this callback will be called.
  void _emailCallback() async
  {
    _email = _controller.text.trim();
    setState(()
    {
      if(_buttonState == 0)
      {
        setState(() 
        {
          _buttonState = 1;  
        });
      }
    });

    Future<String> databaseAnswer = _auth.handleUser(_username, _email, _password);

    databaseAnswer.then((value) 
    {
      if(value == null)
      {
        setState(() 
        {
          _buttonState = 2;  
        });
        Timer(Duration(milliseconds: 500), ()
        {
          Navigator.of(context).pushNamedAndRemoveUntil('root-page', (Route<dynamic> route) => false);
        });
      }
      else
      {
        setState(() 
        {
          _buttonState = 0;
          _errorMessage = value;
        });
        }
    });
  }

  /// if the password widget is the currently shown widget, this widget will be called.
  void _passwordCallback()
  {
    setState(()
    {
      _password = _controller.text.trim();
      _type = Login.EMAIL;
    });
  }

  /// if the widgets represents the username widget, this callback is called
  void _usernameCallback()
  {
    setState(()
    {
      _username = _controller.text.trim();
       _type = Login.PASSWORD;
    });
    }
  
  /// handles all presses on the "next" button and calls the connected method
  void _callback()
  {
    if( _type == Login.EMAIL)
    {
      _emailCallback();
    }
    else if( _type == Login.PASSWORD)
    {
      _passwordCallback();
      _controller.clear();
    }
    else if( _type == Login.USERNAME)
    {
      _usernameCallback();
      _controller.clear();
    }
    setState(() 
    {
      _firstTap = true;
      _errorMessage = null;
    });
  }

  /// Called each time the textfield`s value changes and updates the errorMessage accordingly
  void errorMessageHandle(String value)
  {
    setState(() 
    {
      _firstTap = false;
    });

    if( _type == Login.EMAIL)
    {
      setState(() 
      {
        value.length != 0 ? _errorMessage = null :  _errorMessage = null;
      });
    }
    else if(  _type == Login.PASSWORD)
    {
      setState(()
      {
        value.length > 7 ? _errorMessage = null : _errorMessage = "Your password has to be at least 8 characters";
      });
    }
    else if(  _type == Login.USERNAME)
    {
      setState(() async
      {
        value.length > 3? _errorMessage = null : _errorMessage = "Your username has to be at least 4 character";
        if(await Auth.checkIfUsernameExits(_controller.text))
        {
          _errorMessage = "Username is already in use";
        }
      }); 
    }
  }

  /// Manages the press on the back button
  /// Moves one state backwards
  /// If the last state has been reached, return to Welcome Page
  void _handleBackButtonPress()
  {
    setState(() 
    {
     _firstTap = true;  
     _buttonState = 0;
     _errorMessage = null;
    });
    if( _type == Login.USERNAME)
    {
      Navigator.pop(context);
    }  
    else if( _type == Login.PASSWORD)
    {
      setState(() 
      {
         _type = Login.USERNAME;  
      });
    }
    else if( _type == Login.EMAIL)
    {
      setState(() 
      {
         _type = Login.PASSWORD;  
      });
    }     
  }

  /// returns the spacing above the "next" button and is dependend whether the keyboard is visible
  Widget buildSubmitButton()
  {
    return _keyBoardVisible() ? 
      SizedBox(
        height: height*0.4,
      )
     : SizedBox(
       height: height*0.1,
     );
  }

  /// returns the content of the "Next" button at the bottom of the screen
  /// content can be changed by changing the _buttonState
  Widget getButtonChild()
  {
    if(_buttonState == 0)
    {
      return Center(
        child: Text(
          "Next",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white
          )
        ),
      );
    }
    else if(_buttonState == 1)
    {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
    else if(_buttonState == 2)
    {
      return Icon(Icons.check, color: Colors.white);
    }
    return null;
  }

  Widget getNextButton()
  {
    return FlatButton(
      child: Container(
        height: height * 0.06,
        width: width * 0.6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
        color: _errorMessage == null && !_firstTap ? Colors.blueAccent : Colors.grey
        ),
        child: getButtonChild()
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30)
      ),
      onPressed: _errorMessage == null && !_firstTap ?() 
      {
        _callback(); 
      } : null,
    );
  }

  Widget getTextField()
  {
    return Container(
      width: width*0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
             _type == Login.USERNAME ? "USERNAME":
             _type == Login.EMAIL ? "E-MAIL":
            "PASSWORD",      
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700]
            )
          ),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType:  _type == Login.EMAIL ? TextInputType.emailAddress : null,
            obscureText:  _type == Login.PASSWORD ? true : false,
            onChanged: errorMessageHandle,
            decoration: InputDecoration(
              errorText: _errorMessage,
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey[700]
                )
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getDescriptionText()
  {
    return  Container(
      width: width *0.7,
      child: Center(
        child: Text(
           _type == Login.PASSWORD ? "Your password has to contain at least 8 characters":
           _type == Login.USERNAME ? "Your friends can add you with your username":
          "We need to validate your E-Mail address",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: 16
          ),
        ),
      ),
    );
  }

  Widget getTitleText()
  {
    return  Center(
      child: Text(
         _type == Login.USERNAME ? "Select your username" :
         _type == Login.EMAIL ? "Enter your E-Mail address":
        "Enter a strong password",
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 26
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        
        leading: IconButton(
          icon: Icon(Icons.navigate_before, color: Colors.black, size: 30,),
          onPressed: _handleBackButtonPress,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: height * 0.01,
          ),
          getTitleText(),
          SizedBox(
            height: height*0.02,
          ),
          getDescriptionText(),
          SizedBox(
            height: height * 0.1,
          ),
          getTextField(),
          buildSubmitButton(),
          getNextButton()
        ],
      ),
    );
  }
}