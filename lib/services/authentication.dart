import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth 
{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static String userID;
  static SharedPreferences _preferences;

  static String getUserID() 
  {
    return userID;
  }

  static void setUserID(String newUserID)
  {
    userID = newUserID;
  }

  /// check if user exists in the database 
  /// @param username the username which should be checked
  static Future<bool> checkIfUsernameExits(String username) async
  {
    DocumentSnapshot ds = await Firestore.instance.collection("usernames").document(username).get();
    return ds.exists;
  }

  /// sign in a user with email and password
  /// @param email the email address
  /// @param password the password
  Future<String> signInUser(String email, String password) async
  {
    try
    {
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      assert( user != null);
      userID = user.uid;
      _preferences = await SharedPreferences.getInstance();
      _preferences.setStringList("recentSearches", []);
    } 
    catch(exception)
    {
      print(exception.code);
      switch(exception.code)
      {
        case "ERROR_INVALID_EMAIL":
        {
         return "Oops! This E-Mail address seems to be invalid";
        }
        case "ERROR_WEAK_PASSWORD":
        {
          return "Your password is to weak";
        }
        case "ERROR_EMAIL_ALREADY_IN_USE":
        {
          return "This E-Mail address is already in use";
        }
        case "ERROR_NETWORK_REQUEST_FAILED":
        {
          return "Network error";
        }
        case "ERROR_WRONG_PASSWORD":
        {
          return "Wrong password";
        }
        case "ERROR_USER_NOT_FOUND":
        {
          return "User not found. Have you registered yet?";
        }
      }
    }
    return null;
  }

  Future<String> handleUser(String username, String email, String password) async 
  {
    try
    {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
      FirebaseUser user = result.user;
      if(user != null)
      {
        Firestore.instance.collection("users").document(user.uid).setData(
        {
          'id' : user.uid,
          'username': username,
          'e-mail': email,
          'friends' : [],
          'friendsId' : [],
          'stories': {},
          'requests' : [],
          'online' : false
        });
        userID = user.uid;
      }
    }
    catch(e)
    {
      print(e.code);
      switch(e.code)
      {
        case "ERROR_INVALID_EMAIL":
        {
         return "Oops! This E-Mail address seems to be invalid";
        }
        case "ERROR_WEAK_PASSWORD":
        {
          return "Your password is too weak";
        }
        case "ERROR_EMAIL_ALREADY_IN_USE":
        {
          return "This E-Mail address is already in use";
        }
      }
    }
    return null;
  }

  void setOnlineStatus(bool online)
  {
    Firestore.instance.collection("users").document(userID).setData(
      {
        'online' : online
      }
    );
  }

  Future<void> signOut() async
  {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async 
  {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<bool> isUserLoggedIn() async
  {
    var user = _auth.currentUser();
    return user != null;
  }

  Future<FirebaseUser> getCurrentUser() async 
  {
    return await _auth.currentUser();
  }
}
