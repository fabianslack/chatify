import 'dart:io';

import 'package:chatapp/services/authentication.dart';
import 'package:chatapp/services/db_handler.dart';
import 'package:chatapp/services/storage_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSettingsPage extends StatefulWidget {
  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  String mail, username, password;

  Future<void> placeholder() async {
    return;
  }

  Future<void> getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    File croppedImage = await ImageCropper.cropImage(
        sourcePath: image.path,
        maxWidth: 1080,
        maxHeight: 1080,
        aspectRatioPresets: [CropAspectRatioPreset.square]);
    if (croppedImage != null) {
      image = croppedImage;
      setState(() {});
    }
    Storage().setUserImage(image.path);
    setState(() {});
    Future.delayed(Duration(seconds: 2), () {
      setState(() {});
    });
  }

  showMailDia() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Neue E-Mail eingeben'),
          content: Container(
            height: 150,
            child: Column(
              children: [
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(hintText: 'Neue E-Mail Adresse'),
                  onChanged: (value) => mail = value.trim(),
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      InputDecoration(hintText: "Passwort zur Bestätigung"),
                  onChanged: (value) => password = value.trim(),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                Navigator.pop(context);
                //Auth().setUserMail(mail, password);
              },
            )
          ],
        );
      },
    );
  }

  showNameDia() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Neuen Namen eingeben'),
          content: TextFormField(
            decoration: InputDecoration(hintText: "Name..."),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => username = value.trim(),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                Db().setUsername(username);
                Navigator.pop(context);
                setState(() {});
              },
            )
          ],
        );
      },
    );
  }

  Widget getUserImageRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: FutureBuilder(
            future: Db().getUserImageRef(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return Container(
                      width: 190.0,
                      height: 190.0,
                      padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: new NetworkImage(snapshot.data),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: -10,
                            right: -10,
                            child: IconButton(
                              icon: Icon(Icons.terrain),
                              onPressed: () {
                                getImage();
                              },
                            ),
                          )
                        ],
                      ));
                } else {
                  return Container(
                      height: 190,
                      child: Row(
                        children: [
                          Text("Kein Profilbild"),
                          IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                getImage();
                              }),
                        ],
                      ));
                }
              } else if (snapshot.connectionState == ConnectionState.none) {
                return Text("No Connection");
              }
              return Container(
                  height: 190,
                  width: 190,
                  child: Center(
                      child: Stack(children: [
                    CircularProgressIndicator(),
                  ])));
            },
          ),
        ),
      ],
    );
  }

  Widget getUsernameButton() {
    return FlatButton(
      onPressed: () {
        showNameDia();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Username: "),
          FutureBuilder(
            future: Db().getUsername(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data);
              }
              return Text("loading...");
            },
          )
        ],
      ),
    );
  }

  Widget getUsermailButton() {
    return FlatButton(
      onPressed: () {
        showMailDia();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("E-Mail: "),
          FutureBuilder(
            future: Firestore.instance.collection("users").document(Auth.getUserID()).get().then((value) => value.data["e-mail"]),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data);
              }
              return Text("loading...");
            },
          )
        ],
      ),
    );
  }

  Widget getUserWidget() {
    return RefreshIndicator(
      onRefresh: () {
        setState(() {});
        return placeholder();
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 64),
                getUserImageRow(),
                SizedBox(height: 64),
                getUsernameButton(),
                SizedBox(height: 32),
                getUsermailButton(),
                SizedBox(height: 32),
              ],
            ),
          ),
          height: MediaQuery.of(context).size.height,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getUserWidget(),
    );
  }
}
