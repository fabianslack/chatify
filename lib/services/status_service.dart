import 'package:chatapp/widgets/status_bar_item.dart';
import 'package:firebase_database/firebase_database.dart';

class StatusService {
  static final _firebaseRef =
      FirebaseDatabase.instance.reference().child("status");
  static List<StatusBarItem> _stories = List();

  static void loadStories() {
    _firebaseRef.once().then((value) {
      _stories.add(StatusBarItem(value.value["name"], value.value["image"]));
    });
  }

  static List<StatusBarItem> getStories() {
    loadStories();
    return _stories;
  }
}
