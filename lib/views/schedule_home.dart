library devfest_florida_app.home;

import 'dart:collection';
import 'dart:developer';
import 'package:devfest_florida_app/data/schedule.dart';
import 'package:devfest_florida_app/data/session.dart';
import 'package:devfest_florida_app/data/speaker.dart';
import 'package:devfest_florida_app/views/session_detail.dart';
import 'package:devfest_florida_app/views/shared/drawer.dart';
import 'package:devfest_florida_app/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart' as fireb;
import 'package:firebase_database/firebase_database.dart';

import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

class ConfAppHomeState extends State<ScheduleHomeWidget> {
  final reference = FirebaseDatabase.instance.reference().child('2017');
  LinkedHashMap<String, Session> sessions = kSessions;
  LinkedHashMap<String, Speaker> speakers = kSpeakers;
  List<TimeSlot> timeSlots = <TimeSlot>[];
  List<Schedule> schedules = <Schedule>[];
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    kSpeakers.clear();
    kSessions.clear();
    kTimeSlots.clear();
    loadData();
  }

  Future loadData() async {
    await loadDataFromFireBase();
  }

  Future loadDataFromFireBase() async {
    reference.onChildAdded.forEach((e) {
      fireb.DataSnapshot d = e.snapshot;
      if (d.key == 'sessions') {
        LinkedHashMap hashMap = e.snapshot.value;
        hashMap.forEach((key, value) {
          Session session = new Session.loadFromFireBase(key, value);
          sessions.putIfAbsent(session.id, () => session);
        });
        setState(() {
          kSessions = sessions;
          _setStoredFavorites();
        });
      } else if (d.key == 'speakers') {
        LinkedHashMap hashMap = e.snapshot.value;
        hashMap.forEach((key, value) {
          Speaker speaker = new Speaker.loadFromFireBase(key, value);
          speakers.putIfAbsent(speaker.id, () => speaker);
        });
        setState(() {
          kSpeakers = speakers;
        });
      } else if (d.key == 'schedule') {
        for (LinkedHashMap map in d.value) {
          Schedule schedule = new Schedule.loadFromFireBase(d.key, map);
          kSchedules.add(schedule);
          kSchedules.first.timeSlots.forEach((timeSlot) {
            timeSlots.insert(timeSlots.length, timeSlot);
          });
          setState(() {
            kTimeSlots = timeSlots;
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

  Widget buildScheduledSession(BuildContext context, TimeSlot timeSlot) {
    return new ScheduledSessionWidget(
      timeSlot: timeSlot,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> timeSlotWidgets = <Widget>[];
    kTimeSlots.forEach((timeSlot) {
      timeSlotWidgets.add(buildScheduledSession(context, timeSlot));
    });

    return new Scaffold(
      appBar: new AppBar(
          title: new Text(
        kAppTitle,
        style: new TextStyle(color: Colors.white, fontSize: 24.0),
      )),
      drawer: new ConfAppDrawer(),
      body: new Scrollbar(
        child: new ListView(
          padding: new EdgeInsets.symmetric(vertical: 8.0),
          children: kTimeSlots.length > 0 ? timeSlotWidgets : null,
        ),
      ),
    );
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
    return new Container(
      decoration: new BoxDecoration(
          border: new Border(
        bottom: new BorderSide(color: kColorDivider, width: .5),
      )),
      child: new Container(child: buildRow()),
    );
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
          kSelectedTimeslot = timeSlot;
          log('card tapped');
          Timeline.instantSync('Start Transition', arguments: <String, String>{
            'from': '/',
            'to': SessionDetailsWidget.routeName
          });
          Navigator.pushNamed(context, SessionDetailsWidget.routeName);
        },
        child: new Container(
          margin: new EdgeInsets.only(left: kPadding, top: kMaterialPadding, right: kPadding),
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
                ]
              ),
              new Row(children: <Widget>[
                new Container(
                  padding: const EdgeInsets.only(top: kMaterialPadding),
                  child: new Text(speakerString,
                          style: new TextStyle(fontSize: 16.0,
                          color: kColorText)),
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
                                color: kColorText,
                                fontSize: 16.0
                              ),
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
                            : new Icon(Icons.star_border, color: kColorFavoriteOff),
                      ),
                    ]),
                  ]),
            ],
          ),
        ),
      )
    );
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
      margin: const EdgeInsets.only(left: 4.0, right: kMaterialPadding, top:kMaterialPadding, bottom: kMaterialPadding),
      child: new Row(
        children: [
          new Column(children: <Widget>[
            new Container(
                margin: const EdgeInsets.only(right: 4.0, top: kMaterialPadding),
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
    session.speakers.forEach((speakerId) {
      if (kSessions.containsKey(speakerId.toString())) {
        Speaker speaker = kSpeakers[speakerId.toString()];
        speakerString += speaker.name + ", ";
      }
    });
    speakerString = speakerString.substring(0, speakerString.length - 2);
    return speakerString;
  }
}
