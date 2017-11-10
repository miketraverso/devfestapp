import 'dart:collection';

import 'package:devfest_florida_app/data/timeslot.dart';
class Schedule {
  int id;
  String scheduleId;
  String date;
  String dateReadable;
  List<TimeSlot> timeSlots = <TimeSlot>[];

  Schedule.loadFromFireBase(String key, LinkedHashMap map) {
    scheduleId = key;
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
              TimeSlot timeSlot = new TimeSlot.loadFromFireBase(map["date"], timeSlotMap);
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