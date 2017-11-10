import 'dart:collection';

import 'package:devfest_florida_app/data/timeslot.dart';
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