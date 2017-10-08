import 'dart:collection';

class Session {
  int _attendeeCount = 0;		// Underscore denotes private field
  bool isFavorite = false;
  String id, description, title, track = "", room = "";
  List<String> speakers = <String>[];

  // Constructor
  Session(this.title, this.description, this.track, this.speakers,
      {this.room, this.isFavorite});

  // Named Constructor
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

  // Getter
  int get attendeeCounter => _attendeeCount;

  // Setter
  void set attendeeCounter(int count) {
    this._attendeeCount = count;
  }

  @override
  String toString() {
    // Override toString()
    return 'Session: $title\nSpeakers: $speakers\nTrack: $track\nExpected Attendees: $_attendeeCount';
  }
}

void main() {
  var session = new Session("Science: More art than science.",
      "Wubbalubbadubdub...",
      "DevFest Florida",
      <String>["Rick", "Morty"]);

  print('Before Attendees Set:\n$session\n\n');

  session.attendeeCounter = 10;

  print('After Attendees Set:\n$session');
}
