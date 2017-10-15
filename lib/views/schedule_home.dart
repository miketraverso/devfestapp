library devfest_florida_app.home;

import 'dart:async';
import 'dart:collection';

import 'package:devfest_florida_app/data/schedule.dart';
import 'package:devfest_florida_app/data/session.dart';
import 'package:devfest_florida_app/data/speaker.dart';
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

  LinkedHashMap<String, Session> _sessionsMap = kSessions;
  LinkedHashMap<String, Speaker> _speakersMap = kSpeakers;
  LinkedHashMap<int, Schedule> _allSchedulesMap =
      new LinkedHashMap<int, Schedule>();
  LinkedHashMap<int, List<TimeSlot>> _timeSlotsByScheduleMap =
      new LinkedHashMap<int, List<TimeSlot>>();

  var _schedules = <Schedule>[];

  int _counter = 0;
  static const MethodChannel _methodChannel =
  const MethodChannel("samples.flutter.io/platform_view");

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    kSpeakers.clear();
    kSessions.clear();
    kSchedules.clear();

    loadDataFromFireBase();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future loadDataFromFireBase() async {
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
      _timeSlotsByScheduleMap[scheduleIndex] = <TimeSlot>[];
      Schedule schedule =
          new Schedule.loadFromFireBase(scheduleIndex.toString(), map);
      _schedules.add(schedule);
      _allSchedulesMap.putIfAbsent(scheduleIndex, () => schedule);
      schedule.timeSlots.forEach((timeSlot) {
        _timeSlotsByScheduleMap[scheduleIndex]
            .insert(_timeSlotsByScheduleMap[scheduleIndex].length, timeSlot);
      });
      scheduleIndex += 1;
    });
    setState(() {
      kSchedules = _schedules;
      _tabController =
          new TabController(vsync: this, length: kSchedules.length);
    });
  }

  void createSpeakersFromSnapshot(fireb.Event event) {
    if (event.snapshot.value is LinkedHashMap) {
      LinkedHashMap hashMap = event.snapshot.value;
      hashMap.forEach((key, value) {
        Speaker speaker = new Speaker.loadFromFireBase(key, value);
        _speakersMap.putIfAbsent(speaker.id, () => speaker);
      });
      setState(() {
        kSpeakers = _speakersMap;
      });
    } else {
      List list = event.snapshot.value;
      list.forEach((value) {
        if (value != null) {
          Speaker speaker = new Speaker.loadFromFireBase("speaker", value);
          _speakersMap.putIfAbsent(speaker.id, () => speaker);
        }
      });
      setState(() {
        kSpeakers = _speakersMap;
      });
    }
  }

  void createSessionsFromSnapshot(fireb.DataSnapshot dataSnapshot) {
    LinkedHashMap hashMap = dataSnapshot.value;
    hashMap.forEach((key, value) {
      Session session = new Session.loadFromFireBase(key, value);
      _sessionsMap.putIfAbsent(session.id, () => session);
    });
    setState(() {
      kSessions = _sessionsMap;
      _setStoredFavorites();
    });
  }

  _setStoredFavorites() async {
    kSessions.values.forEach((session) async {
      session.isFavorite = await _isFavorite(session);
    });
  }

  Future<bool> _isFavorite(Session session) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteSessions = prefs.getStringList("favoriteSessions");
    if (favoriteSessions == null) {
      return false;
    }
    if (favoriteSessions.contains(session.id)) {
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
              tabs: kSchedules
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
    for (Schedule schedule in kSchedules) {
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
