import 'dart:collection';

class Session {
  String id;
  bool isFavorite = false;
  String description;
  String title;
  String track;
  String room;
  List<int> speakers = <int>[];

  Session.loadFromFireBase(String fbKey, LinkedHashMap map) {
    id = fbKey;
    for (String key in map.keys) {
      switch (key) {
        case 'description':
          this.description = map[key];
          break;
        case 'room':
          this.room = map[key];
          break;
        case 'title':
          this.title = map[key];
          break;
        case 'track':
          this.track = map[key];
          break;
        case 'speakers':
          this.speakers = map[key];
          break;
      }
    }
  }
}
