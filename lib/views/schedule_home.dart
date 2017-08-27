library devfest_florida_app.home;

import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:devfest_florida_app/data/schedule.dart';
import 'package:devfest_florida_app/data/session.dart';
import 'package:devfest_florida_app/data/speaker.dart';
import 'package:devfest_florida_app/main.dart';
import 'package:devfest_florida_app/views/session_detail.dart';
import 'package:devfest_florida_app/views/shared/drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart' as fireb;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  ConfAppHomeState createState() => new ConfAppHomeState();
}

class ConfAppHomeState extends State<ScheduleHomeWidget>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  LinkedHashMap<String, Session> _sessionsMap = kSessions;
  LinkedHashMap<String, Speaker> _speakersMap = kSpeakers;
  LinkedHashMap<int, Schedule> _allSchedulesMap
    = new LinkedHashMap<int, Schedule>();
  LinkedHashMap<int, List<TimeSlot>> _timeSlotsByScheduleMap
    = new LinkedHashMap<int, List<TimeSlot>>();

  var _schedules = <Schedule>[];

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
    final reference = FirebaseDatabase.instance.reference().child(firebaseRootNode);
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
}

class ScheduledSessionWidget extends StatefulWidget {
  final TimeSlot timeSlot;

  ScheduledSessionWidget({this.timeSlot});

  @override
  SessionState createState() => new SessionState(timeSlot: timeSlot);
}

class SessionState extends State<ScheduledSessionWidget> {
  final TimeSlot timeSlot;

  SessionState({this.timeSlot});

  final sessionWidgets = <Widget>[];
  final sessionRows = <Widget>[];

  void toggleFavorite(Session session) {
    setState(() {
      if (session.isFavorite) {
        session.isFavorite = false;
        _unFavorite(session);
      } else {
        session.isFavorite = true;
        _favorite(session);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kSessions.length > 0 && kSpeakers.length > 0) {
      return new Container(
        decoration: new BoxDecoration(
            border: new Border(
          bottom: new BorderSide(color: kColorDivider, width: .5),
        )),
        child: new Container(child: buildRow()),
      );
    } else {
      return new Container(child: new Text('Loading'));
    }
  }

  _unFavorite(Session session) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteSessions = prefs.getStringList("favoriteSessions");
    if (favoriteSessions == null) {
      return;
    }
    if (favoriteSessions.contains(session.id)) {
      List<String> updatedFavorites = new List<String>();
      updatedFavorites.addAll(favoriteSessions);
      updatedFavorites.remove(session.id);
      prefs.setStringList("favoriteSessions", updatedFavorites);
    }
  }

  _favorite(Session session) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteSessions = prefs.getStringList("favoriteSessions");
    if (favoriteSessions == null) {
      favoriteSessions = <String>[];
    }
    if (!favoriteSessions.contains(session.id)) {
      List<String> updatedFavorites = new List<String>();
      updatedFavorites.addAll(favoriteSessions);
      updatedFavorites.add(session.id);
      prefs.setStringList("favoriteSessions", updatedFavorites);
    }
  }

  Widget buildSessionCard(Session session) {
    String speakerString = getSpeakerNames(session);
    Widget card = new Card(
        child: new GestureDetector(
      onTap: () {
        kSelectedSession = session;
        kSelectedTimeSlot = timeSlot;
        Timeline.instantSync('Start Transition', arguments: <String, String>{
          'from': '/',
          'to': SessionDetailsWidget.routeName
        });
        Navigator.pushNamed(context, SessionDetailsWidget.routeName);
      },
      child: new Container(
        margin: new EdgeInsets.only(
            left: kPadding, top: kMaterialPadding, right: kPadding),
        color: Colors.white,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Row(children: <Widget>[
              new Expanded(
                child: new Text(
                  session.title,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: new TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ]),
            new Row(children: <Widget>[
              new Container(
                padding: const EdgeInsets.only(top: kMaterialPadding),
                child: new Text(speakerString,
                    style: new TextStyle(fontSize: 15.0, color: kColorText)),
              ),
            ]),
            new Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Row(children: <Widget>[
                    new Icon(
                      Icons.location_on,
                      color: kColorText,
                    ),
                    new Expanded(
                      child:new Text(
                        session.room,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: new TextStyle(
                            color: kColorText, fontSize: 14.0),
                      ),
                    ),
                    new IconButton(
                      alignment: FractionalOffset.centerRight,
                      padding: const EdgeInsets.all(0.0),
                      onPressed: () {
                        toggleFavorite(session);
                      },
                      icon: session.isFavorite
                          ? new Icon(Icons.star, color: kColorFavoriteOn)
                          : new Icon(Icons.star_border,
                              color: kColorFavoriteOff),
                    ),
                  ]),
                ]),
          ],
        ),
      ),
    ));
    return card;
  }

  Widget buildRow() {
    List<Widget> sessionCards = <Widget>[];
    sessionWidgets.clear();
    timeSlot.sessions.forEach((sessionId) {
      Session session = kSessions[sessionId.toString()];
      Widget sessionCard = buildSessionCard(session);
      sessionCards.add(sessionCard);
    });

    Widget titleSection = new Container(
      margin: const EdgeInsets.only(
          left: 4.0,
          right: kMaterialPadding,
          top: kMaterialPadding,
          bottom: kMaterialPadding),
      child: new Row(
        children: [
          new Column(children: <Widget>[
            new Container(
                margin:
                    const EdgeInsets.only(right: 4.0, top: kMaterialPadding),
                child: new SizedBox(
                    width: 64.0,
                    child: new Text(
                      sessionTimePeriod(timeSlot),
                      textAlign: TextAlign.right,
                      style: new TextStyle(fontSize: 15.0),
                    ))),
          ]),
          new Expanded(
              child: new Column(
            children: sessionCards,
          )),
        ],
      ),
    );

    return titleSection;
  }

  String getSpeakerNames(Session session) {
    var speakerString = "";
    if (session != null && session.speakers != null) {
      session.speakers.forEach((speakerId) {
        if (kSessions.containsKey(speakerId.toString())) {
          Speaker speaker = kSpeakers[speakerId.toString()];
          speakerString += speaker.name + ", ";
        }
      });
      if (speakerString.length > 2) {
        speakerString = speakerString.substring(0, speakerString.length - 2);
      }
    }
    return speakerString;
  }

  String sessionTimePeriod(TimeSlot timeSlot) {
    return formatter.format(timeSlot.startDate).replaceAll(" ", "")
        + "\nto\n"
        + formatter.format(timeSlot.endDate).replaceAll(" ", "");
  }
}
