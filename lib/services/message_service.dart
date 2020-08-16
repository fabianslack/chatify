import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MessageService {
  var _firebaseRef = FirebaseDatabase().reference().child('chats');

  void sendMessage(String message) {
    _firebaseRef.push().set({
      'message': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    });
  }

  StreamBuilder getStream() {
    return StreamBuilder(
        stream: _firebaseRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              !snapshot.hasError &&
              snapshot.data.snapshot.data != null) {
            Map data = snapshot.data.snapshot.value;
            List item = [];

            data.forEach((key, value) {
              item.add({"key": key, ...data});
            });

            return ListView.builder(
              itemCount: item.length,
              itemBuilder: (context, index) {
                return ListTile(
                    title: Text(item[index]['message']),
                    trailing: Text(item[index]['timestamp']));
              },
            );
          }
        });
  }
}
