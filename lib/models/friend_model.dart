
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendModel
{
  String _name;
  String _id;
  String _imageRef;

  FriendModel.fromDocumentSnapshot(DocumentSnapshot snapshot)
  {
    _name = snapshot["name"];
    _id = snapshot["id"];
    _imageRef = snapshot["profileUrl"];
  }

  String name() => _name;
  String id() => _id;
  String profileImage() => _imageRef;
}