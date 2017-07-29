import 'dart:async';
import 'dart:collection';

import 'package:devfest_florida_app/data/schedule.dart';
import 'package:devfest_florida_app/data/session.dart';
import 'package:devfest_florida_app/data/speaker.dart';
import 'package:devfest_florida_app/views/schedule_home.dart';
import 'package:devfest_florida_app/views/speaker_detail.dart';
import 'package:devfest_florida_app/views/speaker_list.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

List<TimeSlot> kTimeSlots = <TimeSlot>[];
LinkedHashMap<String, Speaker> kSpeakers = new LinkedHashMap<String, Speaker>();
LinkedHashMap<String, Session> kSessions = new LinkedHashMap<String, Session>();
List<Schedule> kSchedules = <Schedule>[];
Speaker kSelectedSpeaker;

final ThemeData kTheme = new ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
);

final String kAppTitle = 'DevFest Florida';
const double kPadding = 12.0;
final Color kColorFavoriteOn = Colors.orange[500];
final Color kColorFavoriteOff = Colors.orange[100];

class DevFestApp extends StatefulWidget {
  const DevFestApp({this.onSendFeedback, Key key}) : super(key: key);

  final VoidCallback onSendFeedback;

  @override
  ConfAppState createState() => new ConfAppState();
}

class ConfAppState extends State<DevFestApp> {
  TargetPlatform _platform;

  @override
  Widget build(BuildContext context) {
    var routes = <String, WidgetBuilder>{
      ScheduleHomeWidget.routeName: (BuildContext context) =>
          new ScheduleHomeWidget(),
      SpeakerListWidget.routeName: (BuildContext context) =>
          new SpeakerListWidget(),
      SpeakerDetailsWidget.routeName: (BuildContext context) =>
          new SpeakerDetailsWidget(),
    };

    return new MaterialApp(
      title: kAppTitle,
      theme: kTheme.copyWith(platform: _platform),
      routes: routes,
      home: new ScheduleHomeWidget(),
    );
  }
}

void main() {
  runApp(new DevFestApp());
}
