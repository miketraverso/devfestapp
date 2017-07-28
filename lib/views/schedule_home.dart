library devfest_florida_app.home;

import 'dart:collection';
import 'package:devfest_florida_app/data/schedule.dart';
import 'package:devfest_florida_app/data/session.dart';
import 'package:devfest_florida_app/data/speaker.dart';
import 'package:devfest_florida_app/views/shared/drawer.dart';
import 'package:devfest_florida_app/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:firebase_database/firebase_database.dart';

import 'dart:async';

final auth = FirebaseAuth.instance;
const double _kFlexibleSpaceMaxHeight = 256.0;

class ScheduleHomeWidget extends StatefulWidget {
  static const String routeName = '/schedule';

  const ScheduleHomeWidget({
    Key key,
    this.onSendFeedback,
  }) : super(key: key);

  final VoidCallback onSendFeedback;

  @override ConfAppHomeState createState() => new ConfAppHomeState();
}

class ConfAppHomeState extends State<ScheduleHomeWidget> {

  final reference = FirebaseDatabase.instance.reference().child('2017');
  LinkedHashMap<String, Session> sessions = kSessions;
  LinkedHashMap<String, Speaker> speakers = kSpeakers;
  List<TimeSlot> timeSlots = <TimeSlot>[];
  List<Schedule> schedules = <Schedule>[];
  bool isLoaded = false;

  @override void initState() {
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
      fb.DataSnapshot d = e.snapshot;
      if (d.key == 'sessions') {
        LinkedHashMap hashMap = e.snapshot.value;
        hashMap.forEach((key, value) {
          Session session = new Session.loadFromFireBase(key, value);
          sessions.putIfAbsent(session.id, () => session);
        });
        setState(() {
          kSessions = sessions;
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

  Widget buildScheduledSession(BuildContext context, TimeSlot timeSlot) {
    return new ScheduledSession(
      timeSlot: timeSlot,
    );
  }

  @override Widget build(BuildContext context) {
    List<Widget> timeSlotWidgets = <Widget>[];
    kTimeSlots.forEach((timeSlot) {
      timeSlotWidgets.add(buildScheduledSession(context,timeSlot));
    });

    return new Scaffold(
      appBar: new AppBar(title:
      new Text(
        kAppTitle,
        style: new TextStyle(
            color: new Color(0xFFFFFFFF),
            fontSize: 24.0),
      )
      ),
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

class ScheduledSession extends StatelessWidget {
  final TimeSlot timeSlot;
  final List<Widget> sessionWidgets = <Widget>[];
  final List<Widget> sessionRows = <Widget>[];

  ScheduledSession({this.timeSlot});

  Widget buildSessionCard(Session session) {
    String speakerString = getSpeakerNames(session);
    Widget card = new Card (
      child: new Container(
        margin: const EdgeInsets.all(12.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Row(
                children: <Widget>[
                  new Expanded(
                    child: new Text(session.title, maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: new TextStyle(
                        fontSize: 20.0, fontWeight: FontWeight.bold,),),
                  ),
                  new Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                ]
            ),
            new Row(
                children: <Widget>[
                  new Container(
                    padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                    child: new Text(speakerString, style: new TextStyle(
                        fontSize: 16.0, color: Colors.grey[700])),
                  ),
                ]
            ),
            new Stack(
              children: <Widget>[
                new Align(
                    alignment: FractionalOffset.topLeft,
                    child: new Row(
                      children: <Widget>[
                        new Icon(Icons.location_on, color: Colors.grey[700],),
                        new Text(session.room,
                          style: new TextStyle(color: Colors.grey[700],),),
                      ],
                    )
                ),
                new Align(
                  alignment: FractionalOffset.topRight,
                  child: new Icon(Icons.star, color: Colors.red[500]),
                ),
              ],
            ),
          ],
        ),
      ),
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
      margin: const EdgeInsets.all(8.0),
      child: new Row(
        children: [
          new Column(
              children: <Widget>[
                new Container (
                    margin: const EdgeInsets.only(right: 8.0, top: 0.0),
                    child: new SizedBox(
                        width: 58.0,
                        child: new Text(
                          timeSlot.starts + "\nto\n" + timeSlot.ends,
                          textAlign: TextAlign.right,)
                    )
                ),
              ]
          ),
          new Expanded(
              child: new Column(children: sessionCards,)
          ),
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

  @override Widget build(BuildContext context) {
    return new Container(
            decoration: new BoxDecoration(
                border: new Border(
                  bottom: new BorderSide(
                      color: Colors.grey[400],
                      width: .5),
                )
            ),
            child: new Container(
                child: buildRow()
            ),
        )
    ;
  }
}