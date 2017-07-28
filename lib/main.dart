import 'dart:collection';
import 'package:devfest_florida_app/data/schedule.dart';
import 'package:devfest_florida_app/data/session.dart';
import 'package:devfest_florida_app/data/speaker.dart';
import 'package:devfest_florida_app/views/schedule_home.dart';
import 'package:devfest_florida_app/views/speaker_list.dart';
import 'package:flutter/material.dart';

List<TimeSlot> kTimeSlots = <TimeSlot>[];
LinkedHashMap<String, Speaker> kSpeakers = new LinkedHashMap<String, Speaker>();
LinkedHashMap<String, Session> kSessions = new LinkedHashMap<String, Session>();
List<Schedule> kSchedules = <Schedule>[];

final ThemeData _theme = new ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
);

final String kAppTitle = 'DevFest Florida';

class DevFestApp extends StatefulWidget {
  const DevFestApp({this.onSendFeedback, Key key}) : super(key: key);

  final VoidCallback onSendFeedback;

  @override
  ConfAppState createState() => new ConfAppState();
}

class ConfAppState extends State<DevFestApp> {
  TargetPlatform _platform;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var routes = <String, WidgetBuilder>{
      ScheduleHomeWidget.routeName: (BuildContext context) =>
          new ScheduleHomeWidget(),
      SpeakerListWidget.routeName: (BuildContext context) =>
          new SpeakerListWidget()
    };

    return new MaterialApp(
      title: kAppTitle,
      theme: _theme.copyWith(platform: _platform),
      routes: routes,
      home: new ScheduleHomeWidget(),
    );
  }
}

void main() {
  runApp(new DevFestApp());
}
