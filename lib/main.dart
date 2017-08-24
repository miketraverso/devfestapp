import 'dart:collection';

import 'package:devfest_florida_app/data/schedule.dart';
import 'package:devfest_florida_app/data/session.dart';
import 'package:devfest_florida_app/data/speaker.dart';
import 'package:devfest_florida_app/views/location.dart';
import 'package:devfest_florida_app/views/schedule_home.dart';
import 'package:devfest_florida_app/views/session_detail.dart';
import 'package:devfest_florida_app/views/speaker_detail.dart';
import 'package:devfest_florida_app/views/speaker_list.dart';
import 'package:flutter/material.dart';

List<Schedule> kSchedules = <Schedule>[];
LinkedHashMap<String, Speaker> kSpeakers = new LinkedHashMap<String, Speaker>();
LinkedHashMap<String, Session> kSessions = new LinkedHashMap<String, Session>();

Speaker kSelectedSpeaker;
Session kSelectedSession;
TimeSlot kSelectedTimeSlot;

final ThemeData kTheme = new ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
);

const kMaterialPadding = 8.0;
const kPadding = 12.0;
const kPaddingDouble = 24.0;

final kColorFavoriteOn = Colors.orange[500];
final kColorFavoriteOff = Colors.orange[100];
final kColorDivider = Colors.grey[400];
final kColorText = Colors.grey[700];
final kColorTextHeader = Colors.grey[800];
final kColorSpeakerName = Colors.grey[800];

final kAppTitle = 'DevFest Florida';
final kSurveyUrl = 'https://docs.google.com/forms/d/e/1FAIpQLScvVof4YcQiiR0qvAN84rNVsXBLgArTdmOuwFQY4KXK2Tff-g/viewform?entry.385327315=GDG+Sun+Coast';
final kVenueName = 'Disney\'s Contemporary Resort';
final kVenueAddress = '4600 North World Dr.\nOrlando, FL 32830';
final kVenuePhone = '(407) 824-1000';

// Visit http://staticmapmaker.com/google/ to create your own static map
// Flutter can't, at the time of this coding, handle native maps so let's
// provide the user with a map image instead.
final kGoogleStaticMapUrl = 'https://maps.googleapis.com/maps/api/staticmap?center=Disney+Contemporary+Resort&zoom=15&scale=2&size=600x1000&maptype=roadmap&format=png&visual_refresh=true&markers=size:mid%7Ccolor:0xff0000%7Clabel:1%7CDisney+Contemporary+Resort';

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
      SessionDetailsWidget.routeName: (BuildContext context) =>
        new SessionDetailsWidget(),
      LocationWidget.routeName: (BuildContext context) =>
          new LocationWidget()
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
