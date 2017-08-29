import 'dart:collection';

class Schedule {
  String id;
  String date;
  String dateReadable;
  List<TimeSlot> timeSlots = <TimeSlot>[];

  Schedule.loadFromFireBase(String fbKey, LinkedHashMap map) {
    id = fbKey;
    for (String key in map.keys) {
      switch (key) {
        case 'date':
          this.date = map[key];
          break;
        case 'dateReadable':
          this.dateReadable = map[key];
          break;
        case 'timeslots': {
          if (map[key] is List) {
            for (LinkedHashMap timeSlotMap in map[key]) {
              TimeSlot timeSlot = new TimeSlot.loadFromFireBase(key, map["date"], timeSlotMap);
              timeSlots.add(timeSlot);
            }
          }
        }
          break;
        default:
          break;
      }
    }

  }
}

class TimeSlot {
  String id;
  String starts;
  String ends;
  DateTime startDate, endDate;
  List<int> sessions;

  TimeSlot.loadFromFireBase(String fbKey, String date, LinkedHashMap timeSlotMap) {
    id = fbKey;
    for (String key in timeSlotMap.keys) {
      switch (key) {
        case 'starts':
        case 'startTime':
          this.starts = timeSlotMap[key];
          break;
        case 'ends':
        case 'endTime':
          this.ends = timeSlotMap[key];
          break;
        case 'sessions':
          this.sessions = timeSlotMap[key];
          break;
      }
    }
    
    try {
      RegExp expHHMM
        = new RegExp(r"^([ 01]?[0-9]|2[0-3])(:([0-5][0-9]))?$");
      RegExp expHHMMSS
        = new RegExp(r"^([ 01]?[0-9]|2[0-3])(:([0-5][0-9]))(:([0-5][0-9]))?$");

      Iterable<Match> startMatches = expHHMM.allMatches(starts);
      Iterable<Match> endMatches = expHHMM.allMatches(ends);

      if (startMatches.toList().length > 0 && endMatches.toList().length > 0) {
        startDate = DateTime.parse(date + " " + starts);
        endDate = DateTime.parse(date + " " + ends);
      } else {
        startMatches = expHHMMSS.allMatches(starts);
        endMatches = expHHMMSS.allMatches(ends);
        if (startMatches.toList().length > 0 && endMatches.toList().length > 0) {
          startDate = DateTime.parse(date + " " + starts);
          endDate = DateTime.parse(date + " " + ends);
        }
      }
    } catch(exception, stacktrace){
      print(exception);
      print(stacktrace);
    }
  }
}
