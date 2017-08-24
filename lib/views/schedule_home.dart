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

final auth = FirebaseAuth.instance;
const double _kFlexibleSpaceMaxHeight = 256.0;

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

  LinkedHashMap<String, Session> sessionsMap = kSessions;
  LinkedHashMap<String, Speaker> speakersMap = kSpeakers;
  LinkedHashMap<int, List<TimeSlot>> timeSlotsByScheduleMap = new LinkedHashMap<int, List<TimeSlot>>();
  LinkedHashMap<int, Schedule> allSchedulesMap = new LinkedHashMap<int, Schedule>();

  List<TimeSlot> timeSlotsList = <TimeSlot>[];
  List<Schedule> schedules = <Schedule>[];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    kSpeakers.clear();
    kSessions.clear();
    kTimeSlots.clear();
    kSchedules.clear();
    kAllSchedules.clear();

    loadDataFromFireBase();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future loadDataFromFireBase() async {
    final reference = FirebaseDatabase.instance.reference().child('2017');
    reference.onChildAdded.forEach((e) {
      fireb.DataSnapshot d = e.snapshot;
      if (d.key == 'sessions') {
        LinkedHashMap hashMap = e.snapshot.value;
        hashMap.forEach((key, value) {
          Session session = new Session.loadFromFireBase(key, value);
          sessionsMap.putIfAbsent(session.id, () => session);
        });
        setState(() {
          kSessions = sessionsMap;
          _setStoredFavorites();
        });
      } else if (d.key == 'speakers') {
        LinkedHashMap hashMap = e.snapshot.value;
        hashMap.forEach((key, value) {
          Speaker speaker = new Speaker.loadFromFireBase(key, value);
          speakersMap.putIfAbsent(speaker.id, () => speaker);
        });
        setState(() {
          kSpeakers = speakersMap;
        });
      } else if (d.key == 'schedule') {
        if (d.value is List) {
          int index = 0;
          d.value.forEach((LinkedHashMap map) {
            timeSlotsByScheduleMap[index] = <TimeSlot>[];
            Schedule schedule =
                new Schedule.loadFromFireBase(index.toString(), map);
            schedules.add(schedule);
            allSchedulesMap.putIfAbsent(index, () => schedule);
            schedule.timeSlots.forEach((timeSlot) {
              timeSlotsByScheduleMap[index]
                  .insert(timeSlotsByScheduleMap[index].length, timeSlot);
            });
            index += 1;
          });
          setState(() {
            kSchedules = schedules;
            kAllSchedules = allSchedulesMap;
            _tabController = new TabController(
                vsync: this, length: kSchedules.length);
          });
        } else {
          for (LinkedHashMap map in d.value) {
            Schedule schedule = new Schedule.loadFromFireBase(d.key, map);
            kSchedules.add(schedule);
            kSchedules.first.timeSlots.forEach((timeSlot) {
              timeSlotsByScheduleMap[0]
                  .insert(timeSlotsByScheduleMap[0].length, timeSlot);
              timeSlotsList.insert(timeSlotsList.length, timeSlot);
            });
          }
          setState(() {
            kTimeSlots = timeSlotsList;
          });
        }
      }
    });
  }

  _setStoredFavorites() async {
    kSessions.values.forEach((sesh) async {
      sesh.isFavorite = await _isFavorite(sesh);
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
    List dailyScrollingScheduleWidgets = new List();
    for (Schedule schedule in kSchedules) {
      List<Widget> widgetsForDay = new List<Widget>();
      for (TimeSlot slot in schedule.timeSlots) {
        widgetsForDay.add(buildScheduledSession(slot));
      }

      var dayScrollWidget =
        new Scrollbar(
          child: new ListView(
            padding: new EdgeInsets.symmetric(vertical: 8.0),
            children: widgetsForDay,
          ),
        );
      dailyScrollingScheduleWidgets.add(dayScrollWidget);
    }

    List<Widget> tabs = kSchedules.map((Schedule schedule) =>
      new Tab(text: schedule.dateReadable)
    ).toList();

    if (dailyScrollingScheduleWidgets != null
        && dailyScrollingScheduleWidgets.length > 0) {
      return new Scaffold(
        key: _scaffoldKey,
        drawer: new ConfAppDrawer(),
        appBar: new AppBar(
          title: new Text(
            kAppTitle,
            style: new TextStyle(color: Colors.white, fontSize: 24.0),
          ),
          bottom: new TabBar(
            controller: _tabController,
            tabs: tabs,
          ),
        ),
        body: new TabBarView(
          controller: _tabController,
          children: dailyScrollingScheduleWidgets
        )
      );
    } else {
      return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text(
            kAppTitle,
            style: new TextStyle(color: Colors.white, fontSize: 24.0),
          )),
        drawer: new ConfAppDrawer(),
        body: const Center(
          child: const CupertinoActivityIndicator(),
        ),
      );
    }
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
    if (kSessions.length > 0 &&
        kSpeakers.length > 0 &&
        kAllSchedules.length > 0) {
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
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ]),
            new Row(children: <Widget>[
              new Container(
                padding: const EdgeInsets.only(top: kMaterialPadding),
                child: new Text(speakerString,
                    style: new TextStyle(fontSize: 16.0, color: kColorText)),
              ),
            ]),
            new Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Row(children: <Widget>[
                  new Expanded(
                    child: new Row(
                      children: <Widget>[
                        new Icon(
                          Icons.location_on,
                          color: kColorText,
                        ),
                        new Text(
                          session.room,
                          style: new TextStyle(
                              color: kColorText, fontSize: 16.0),
                        ),
                      ],
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
                      timeSlot.starts + "\nto\n" + timeSlot.ends,
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
    String speakerString = "";
    if (session != null && session.speakers != null) {
      session.speakers.forEach((speakerId) {
        if (kSessions.containsKey(speakerId.toString())) {
          Speaker speaker = kSpeakers[speakerId.toString()];
          speakerString += speaker.name + ", ";
        }
      });
      speakerString = speakerString.substring(0, speakerString.length - 2);
    }
    return speakerString;
  }
}
