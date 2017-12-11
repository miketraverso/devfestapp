import 'dart:async';
import 'dart:collection';

import 'package:devfest_florida_app/data/schedule.dart';
import 'package:devfest_florida_app/data/session.dart';
import 'package:devfest_florida_app/data/speaker.dart';
import 'package:devfest_florida_app/data/timeslot.dart';
import 'package:devfest_florida_app/views/location.dart';
import 'package:devfest_florida_app/views/schedule_home.dart';
import 'package:devfest_florida_app/views/session_detail.dart';
import 'package:devfest_florida_app/views/speaker_detail.dart';
import 'package:devfest_florida_app/views/speaker_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

List<Schedule> mSchedules = <Schedule>[];
LinkedHashMap<String, Speaker> mSpeakers = new LinkedHashMap<String, Speaker>();
LinkedHashMap<String, Session> mSessions = new LinkedHashMap<String, Session>();

Speaker mSelectedSpeaker;
Session mSelectedSession;
TimeSlot mSelectedTimeSlot;
String mUuid;
String mdbPath;

// TODO Change your base URL
var baseUrl = "https://devfestnyc.com/";

// TODO Change the navbar color
final ThemeData kTheme = new ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.lightGreen,
);

// TODO Change the font style of the navbar - Ensure font is defined in pubspec.yaml
var navbarFontStyle = new TextStyle(color: Colors.white, fontSize: 24.0, fontFamily: 'ProductSans-Regular');

// TODO Change the logo image - Ensure asset is defined in pubspec.yaml
var logoImage = new Image.asset('assets/images/devfestnyc.png');

// TODO Change the Firebase root node name
var firebaseRootNode = '';

const kMaterialPadding = 8.0;
const kPadding = 12.0;
const kPaddingDouble = 24.0;

// TODO Change the color of the favorite icons (on/off)
final kColorFavoriteOn = Colors.lightGreen[500];
final kColorFavoriteOff = Colors.lightGreen[300];

// TODO Change the color of the dividers
final kColorDivider = Colors.grey[400];

// TODO Change the color of the favorite icon
final kColorText = Colors.grey[700];
final kColorTextHeader = Colors.grey[800];
final kColorSpeakerName = Colors.grey[800];

// TODO Change the locale for hour:minute format
var formatter = new DateFormat.jm('en_US');

// TODO Change app specifics: title, survey url, venue specifics, firebase parent child, etc.
final kAppTitle = 'DevFest NYC 2017';
final kSurveyUrl = 'https://docs.google.com/forms/d/13Bs4pC88mp2_EYUmOm2rhAGEhp7tVuwRKG_u3nR2YuM/viewform?entry.381167392=https://www.meetup.com/gdgnyc/events/242200007/';
final kVenueName = 'Galvanize';
final kVenueAddress = '315 Hudson Street\nNew York, NY 10013';
final kVenuePhone = '';

// TODO Change the url for the location map
// Visit http://staticmapmaker.com/google/ to create your own static map
// Flutter can't, at the time of this coding, handle native maps so let's
// provide the user with a map image instead.
final kGoogleStaticMapUrl = 'https://maps.googleapis.com/maps/api/staticmap?center=315+Hudson+St,+New+York,+NY+10013&zoom=16&scale=2&size=600x1000&maptype=roadmap&format=png&visual_refresh=true&markers=size:mid%7Ccolor:0xff0000%7Clabel:1%7C315+Hudson+St';

class DevFestApp extends StatefulWidget {
  const DevFestApp({Key key}) : super(key: key);

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

    setUuid();

    return new MaterialApp(
      title: kAppTitle,
      theme: kTheme.copyWith(platform: _platform),
      routes: routes,
      home: new ScheduleHomeWidget(),
    );
  }

  Future<Null> setUuid() async {
    if (mUuid == null || mUuid.isEmpty) {
      const uuidKey = "uuid";
      SharedPreferences prefs = await SharedPreferences.getInstance();
      mUuid = prefs.getString(uuidKey);
      if (mUuid == null || mUuid.isEmpty) {
        prefs.setString(uuidKey, new Uuid().v4());
        prefs.commit();
        print(mUuid);
      }
    }
  }
}

void main() {
  runApp(new DevFestApp());
}