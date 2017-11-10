library devfest_florida_app.home;

import 'dart:async';
import 'dart:collection';

import 'package:devfest_florida_app/data/schedule.dart';
import 'package:devfest_florida_app/data/session.dart';
import 'package:devfest_florida_app/data/speaker.dart';
import 'package:devfest_florida_app/data/timeslot.dart';
import 'package:devfest_florida_app/main.dart';
import 'package:devfest_florida_app/views/scheduled_session_widget.dart';
import 'package:devfest_florida_app/views/shared/drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart' as fireb;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/services/platform_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _auth = FirebaseAuth.instance;
const _kFlexibleSpaceMaxHeight = 256.0;

class ScheduleHomeWidget extends StatefulWidget {
  static const routeName = '/schedule';

  const ScheduleHomeWidget({
    Key key,
    this.onSendFeedback,
  })
      : super(key: key);

  final VoidCallback onSendFeedback;

  @override
  ScheduleHomeWidgetState createState() => new ScheduleHomeWidgetState();
}

class ScheduleHomeWidgetState extends State<ScheduleHomeWidget>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  LinkedHashMap<String, Session> _sessionsMap = mSessions;
  LinkedHashMap<String, Speaker> _speakersMap = mSpeakers;

  var _schedules = <Schedule>[];

  int _counter = 0;
  static const MethodChannel _methodChannel =
  const MethodChannel("samples.flutter.io/platform_view");

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    mSpeakers.clear();
    mSessions.clear();
    mSchedules.clear();

    loadFromFireBase();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future loadFromFireBase() async {
    final reference =
        FirebaseDatabase.instance.reference().child(firebaseRootNode);
    reference.onChildAdded.forEach((event) {
      fireb.DataSnapshot dataSnapshot = event.snapshot;
      if (dataSnapshot.key == 'sessions') {
        createSessionsFromSnapshot(dataSnapshot);
      } else if (dataSnapshot.key == 'speakers') {
        createSpeakersFromSnapshot(event);
      } else if (dataSnapshot.key == 'schedule') {
        createScheduleFromSnapshot(dataSnapshot);
      }
    });
  }

  void createScheduleFromSnapshot(fireb.DataSnapshot dataSnapshot) {
    var scheduleIndex = 0;
    dataSnapshot.value.forEach((LinkedHashMap map) {
      Schedule schedule = new Schedule.loadFromFireBase(scheduleIndex.toString(),
          map);
      _schedules.add(schedule);
      scheduleIndex += 1;
    });
    setState(() {
      mSchedules = _schedules;
      _tabController = new TabController(vsync: this, length: mSchedules.length);
    });
  }

  void createSpeakersFromSnapshot(fireb.Event event) {
    if (event.snapshot.value is LinkedHashMap) {
      LinkedHashMap hashMap = event.snapshot.value;
      hashMap.forEach((key, map) {
        Speaker speaker = new Speaker.loadFromFireBase(map);
        _speakersMap.putIfAbsent(speaker.speakerId, () => speaker);
      });
      setState(() {
        mSpeakers = _speakersMap;
      });
    } else {
      List list = event.snapshot.value;
      list.forEach((map) {
        if (map != null) {
          Speaker speaker = new Speaker.loadFromFireBase(map);
          _speakersMap.putIfAbsent(speaker.speakerId, () => speaker);
        }
      });
      setState(() {
        mSpeakers = _speakersMap;
      });
    }

    // TODO: Save speakers to database

  }

  void createSessionsFromSnapshot(fireb.DataSnapshot dataSnapshot) {
    LinkedHashMap hashMap = dataSnapshot.value;
    hashMap.forEach((key, value) async {
      Session session = new Session.loadFromFireBase(key, value);
      session.isFavorite = await FavoriteUtility.isFavorite(session);
      _sessionsMap.putIfAbsent(session.sessionId, () => session);
    });
    setState(() {
      mSessions = _sessionsMap;
      _setStoredFavorites();
    });

    // TODO: Save sessions to database

  }

  _setStoredFavorites() async {
    mSessions.values.forEach((session) async {
      session.isFavorite = await _isFavorite(session);
    });
  }

  Future<bool> _isFavorite(Session session) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteSessions = prefs.getStringList("favoriteSessions");
    if (favoriteSessions == null) {
      return false;
    }
    if (favoriteSessions.contains(session.sessionId.toString())) {
      return true;
    }
    return false;
  }

  Widget buildScheduledSession(TimeSlot timeSlot) {
    return new ScheduledSessionWidget(
      timeSlot: timeSlot,
    );
  }

  @override
  Widget build(BuildContext context) {
    List dailyScrollingScheduleWidgets = createScheduleWidget();

    if (dailyScrollingScheduleWidgets != null &&
        dailyScrollingScheduleWidgets.length > 0) {
      return new Scaffold(
          key: _scaffoldKey,
          drawer: new ConfAppDrawer(),
          appBar: new AppBar(
            title: new Text(
              kAppTitle,
              style: navbarFontStyle,
            ),
            actions: <Widget>[
              new Builder(
                builder: (BuildContext context) {
                  return new IconButton(
                    icon: const Icon(Icons.camera_alt),
                    tooltip: 'Snap a photo',
                    onPressed: () {
                      _launchNativeCamera(context);
                    },
                  );
                },
              ),
            ],
            bottom: new TabBar(
              controller: _tabController,
              tabs: mSchedules
                  .map((Schedule schedule) => new Tab(
                        text: schedule.dateReadable,
                      ))
                  .toList(),
              labelStyle: new TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          body: new TabBarView(
              controller: _tabController,
              children: dailyScrollingScheduleWidgets));
    } else {
      return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
            title: new Text(
          kAppTitle,
          style: navbarFontStyle,
        )),
        drawer: new ConfAppDrawer(),
        body: const Center(
          child: const CupertinoActivityIndicator(),
        ),
      );
    }
  }

  List createScheduleWidget() {
    var dailyScrollingScheduleWidgets = new List();
    for (Schedule schedule in mSchedules) {
      List<Widget> widgetsForDay = new List<Widget>();
      for (TimeSlot slot in schedule.timeSlots) {
        widgetsForDay.add(buildScheduledSession(slot));
      }

      var dayScrollWidget = new Scrollbar(
        child: new ListView(
          padding: new EdgeInsets.symmetric(vertical: 8.0),
          children: widgetsForDay,
        ),
      );
      dailyScrollingScheduleWidgets.add(dayScrollWidget);
    }
    return dailyScrollingScheduleWidgets;
  }


  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<Null> _launchPlatformCount() async {
    final int platformCounter = await _methodChannel.invokeMethod("switchView", _counter);
    setState(() {
      _counter = platformCounter;
    });
  }

  Future<Null> _launchNativeCamera(BuildContext context) async {
    await _methodChannel.invokeMethod("switchView");
    setState(() {
    });
  }
}
