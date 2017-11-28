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
var baseUrl = "https://devfestflorida.org/";

// TODO Change the navbar color
final ThemeData kTheme = new ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
);

// TODO Change the font style of the navbar - Ensure font is defined in pubspec.yaml
var navbarFontStyle = new TextStyle(color: Colors.white, fontSize: 24.0, fontFamily: 'ProductSans-Regular');

// TODO Change the logo image - Ensure asset is defined in pubspec.yaml
var logoImage = new Image.asset('assets/images/devfest-logo.png');

// TODO Change the Firebase root node name
var firebaseRootNode = '2017';

const kMaterialPadding = 8.0;
const kPadding = 12.0;
const kPaddingDouble = 24.0;

// TODO Change the color of the favorite icons (on/off)
final kColorFavoriteOn = Colors.orange[500];
final kColorFavoriteOff = Colors.orange[100];

// TODO Change the color of the dividers
final kColorDivider = Colors.grey[400];

// TODO Change the color of the favorite icon
final kColorText = Colors.grey[700];
final kColorTextHeader = Colors.grey[800];
final kColorSpeakerName = Colors.grey[800];

// TODO Change the locale for hour:minute format
var formatter = new DateFormat.jm('en_US');

// TODO Change app specifics: title, survey url, venue specifics, firebase parent child, etc.
final kAppTitle = 'DevFest Florida';
final kSurveyUrl = 'https://docs.google.com/forms/d/13Bs4pC88mp2_EYUmOm2rhAGEhp7tVuwRKG_u3nR2YuM/viewform?entry.381167392=https://www.meetup.com/GDG-Central-Florida/events/239734946/';
final kVenueName = 'Disney\'s Contemporary Resort';
final kVenueAddress = '4600 North World Dr.\nOrlando, FL 32830';
final kVenuePhone = '(407) 824-1000';

// TODO Change the url for the location map
// Visit http://staticmapmaker.com/google/ to create your own static map
// Flutter can't, at the time of this coding, handle native maps so let's
// provide the user with a map image instead.
final kGoogleStaticMapUrl = 'https://maps.googleapis.com/maps/api/staticmap?center=Disney+Contemporary+Resort&zoom=15&scale=2&size=600x1000&maptype=roadmap&format=png&visual_refresh=true&markers=size:mid%7Ccolor:0xff0000%7Clabel:1%7CDisney+Contemporary+Resort';

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