import 'dart:collection';

final String tableTimeSlot = "timeslot";
final String columnId = "_id";
final String columnStarts = "starts";
final String columnEnds = "ends";
final String columnStartDate = "startsDateSecs";
final String columnEndsDate = "endsDateSecs";
final String columnSessions = "sessions";

class TimeSlot {
  int id;
  String starts;
  String ends;
  int startDateSecs;
  int endDateSecs;
  DateTime startDate, endDate;
  List<int> sessions;

  TimeSlot.loadFromFireBase(String date, LinkedHashMap timeSlotMap) {
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

    setDates(date);
  }

  void setDates(String date) {
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