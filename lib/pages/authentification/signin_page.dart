import 'dart:async';

import 'package:chatapp/services/authentication.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget
{
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> 
{
  TextEditingController _controller = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _validInputUsername = false;
  bool _validInputPassword = false;

  bool _passwordVisible = true;

  String _errorMessage;

  int _buttonState = 0;

  Auth _auth = Auth();

  double _height;
  double _width;

   /// determines whether the keyboard is shown
  bool _keyBoardVisible()
  {
    return (MediaQuery.of(context).viewInsets.bottom == 0);
  }

  void handleBackButton()
  {
    Navigator.pop(context);
  }

  void handleSubmitButton()
  {
    setState(() {
      
      _errorMessage = null;
    });
    if(_buttonState == 0)
    {
      setState(() 
      {
        _buttonState = 1;
      });
    }
    Future<String> answer = _auth.signInUser(_controller.text.trim(), _passwordController.text);
    answer.then((value)
    {
      setState(() 
      {
        _errorMessage = value;
      });

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

  Widget getSpacingAboveSubmitButton()
  {
    return _keyBoardVisible() ? 
      SizedBox(
        height: _height*0.4,
      )
     : SizedBox(
       height: _errorMessage == null ?_height*0.1 : _height*0.1,
     );
  }

  Widget getTitleText()
  {
    return Center(
      child: Text(
        "Login",
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 26
        )
      )
    );
  }

  Widget getUsernameField()
  {
    return Container(
      width: _width * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "USERNAME OR EMAIL",
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
            style: TextStyle(
              color: Colors.black
            ),
            onChanged: (value)
            {
              setState(() 
              {
                _validInputUsername = value.length > 0;
                _errorMessage = null;
              });
            },
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey[700]
                )
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget getPasswordField()
  {
    return Container(
      width: _width * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "PASSWORD",
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700]
            )
          ),
          TextField(
            controller: _passwordController,
            autofocus: true,
            obscureText: _passwordVisible,
            onChanged: (value)
            {
              setState(() {
                _validInputPassword = value.length > 0;
              });
            },
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.ac_unit),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              ),
              errorText: _errorMessage,
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey[700]
                )
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget getForgotPassword()
  {
    return GestureDetector(
      child: Text(
        "Forgot password?",
        style: TextStyle(
          color: _validInputUsername ? Colors.blueAccent : Colors.grey[700],
          fontSize: 12
        )
      ),
      onTap: _validInputUsername ? ()
      { 
        _auth.resetPassword(_controller.text.trim());
      } : () {}
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
          "Submit",
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
      return Container(
        height: _height*0.05,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }
    else if(_buttonState == 2)
    {
      return Icon(Icons.check, color: Colors.white);
    }
    return null;
  }

  Widget getSubmitButton()
  {
    return FlatButton(
      child: Container(
        height: _height * 0.06,
        width: _width * 0.6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
        color: _validInputUsername && _validInputPassword ? Colors.blueAccent : Colors.grey
        ),
        child: getButtonChild(),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30)
      ),
      onPressed: _validInputUsername && _validInputPassword ? () 
      {
        handleSubmitButton();
      } : null,
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.navigate_before, 
            color: Colors.black, 
            size:30,
          ),
          onPressed: handleBackButton,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: _height * 0.01,
          ),
          getTitleText(),
          SizedBox(
            height: _height*0.02,
          ),
          getUsernameField(),
          SizedBox(
            height: _height *0.03,
          ),
          getPasswordField(),
          SizedBox(
            height: _height*0.02,
          ),
          getForgotPassword(),
          getSpacingAboveSubmitButton(),
          getSubmitButton()
        ],
      ),
    );
  }
}