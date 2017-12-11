import 'dart:collection';

class Session {
  int id;
  int _attendeeCount = 0;
  String sessionId;
  String description;
  String title;
  String track = "";
  String room = "";
  bool isFavorite = false;
  List<int> speakers = <int>[];

  // Constructor
  Session(this.title, this.description, this.track, this.speakers,
      {this.room, this.isFavorite});

  // Named Constructor
  Session.loadFromFireBase(String fbKey, LinkedHashMap map) {
    sessionId = fbKey;
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

    if ((room == null || room.isEmpty) && (track == null || track.isEmpty)) {
      track = room = 'TBD';
    }
  }

  // Getter
  int get attendeeCounter => _attendeeCount;

  // Setter
  set attendeeCounter(int count) {
    this._attendeeCount = count;
  }

  @override
  String toString() {
    // Override toString()
    return 'Session: $title\nSpeakers: $speakers\nTrack: $track\nExpected Attendees: $_attendeeCount';
  }
}