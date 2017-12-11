// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:developer';

import 'package:devfest_florida_app/data/rating.dart';
import 'package:devfest_florida_app/data/session.dart';
import 'package:devfest_florida_app/data/speaker.dart';
import 'package:devfest_florida_app/main.dart';
import 'package:devfest_florida_app/util/pluto.dart';
import 'package:devfest_florida_app/views/shared/rating_dialog.dart';
import 'package:devfest_florida_app/views/speaker_detail.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionDetailsWidget extends StatefulWidget {
  static const String routeName = '/sessiondetails';

  @override
  SessionDetailsState createState() => new SessionDetailsState();
}

class SessionDetailsState extends State<SessionDetailsWidget> {
  String roomAndTime() {
    return mSelectedSession.room +
        '\n' +
        formatter.format(mSelectedTimeSlot.startDate).replaceAll(" ", "") +
        ' - ' +
        formatter.format(mSelectedTimeSlot.endDate).replaceAll(" ", "");
  }

  String getCircleDetails(Speaker speaker) {
    String speakerIntials;
    if (speaker.name.split(' ').length >= 2) {
      speakerIntials = speaker.name.split(' ')[0].substring(0, 1) +
          speaker.name.split(' ')[1].substring(0, 1);
    } else {
      speakerIntials = speaker.name.substring(0, 1);
    }

    if (speaker.thumbnailUrl.isEmpty ||
        !(speaker.thumbnailUrl.endsWith("jpg") ||
            speaker.thumbnailUrl.endsWith("jpeg") ||
            speaker.thumbnailUrl.endsWith("png"))) {
      return speakerIntials;
    } else {
      return "";
    }
  }

  Future<Null> _saveRatings(Future<SpeakerRating> ratings, Session session) async {
    ratings.then((rating) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt("overall_" + session.sessionId, rating.overAllRating != null ? rating.overAllRating : 0);
      prefs.setInt("technical_" + session.sessionId, rating.technicalRating != null ? rating.technicalRating : 0);
      prefs.setInt("presentation_" + session.sessionId, rating.presentationRating != null ? rating.presentationRating : 0);
      prefs.commit();

      var uuid = prefs.getString("uuid");

      final reference =
          FirebaseDatabase.instance.reference().child(firebaseRootNode);
      reference
          .child("ratings")
          .child(mSelectedSession.sessionId)
          .child(uuid)
          .set({
        'review': {
          'overall': rating.overAllRating,
          'technical': rating.technicalRating,
          'presentation': rating.presentationRating
        }
      });
    });
  }

  Future<SpeakerRating> _submittedRatings(Session session) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var overall = prefs.getInt("overall_" + session.sessionId);
    var technical = prefs.getInt("technical_" + session.sessionId);
    var presentation = prefs.getInt("presentation_" + session.sessionId);

    SpeakerRating ratings = new SpeakerRating(
        overAllRating: overall != null ? overall : 0,
        technicalRating: technical != null ? technical : 0,
        presentationRating: presentation != null ? presentation : 0);
    return ratings;
  }

  Future<SpeakerRating> _showRatingDialog() async {
    SpeakerRating submittedRating = await _submittedRatings(mSelectedSession);
    StarRatingDialog ratingDialog = new StarRatingDialog(rating: submittedRating);
    return showDialog<SpeakerRating>(
        context: context,
        barrierDismissible: true,
        child: ratingDialog);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> speakerRowWidgets = <Widget>[];
    if (mSelectedTimeSlot.endDate.compareTo(new DateTime.now()) < 0) {
      mSelectedSession.speakers.forEach((speakerId) {
        Speaker speak = mSpeakers[speakerId.toString()];
        String speakerInitials = getCircleDetails(speak);
        Widget speakerRowWidget = new Row(children: <Widget>[
          new Expanded(
              child: new ListTile(
                  leading: new ExcludeSemantics(
                      child: new CircleAvatar(
                        child: speakerInitials.isEmpty
                            ? null
                            : new Text(speakerInitials),
                        backgroundImage: new PlutoImage.networkWithPlaceholder(
                          speak.thumbnailUrl,
                          logoImage,
                          alignment: const FractionalOffset(0.0, 0.0),
                        )
                            .image,
                      )),
                  title: new DefaultTextStyle(
                    style:
                    new TextStyle(color: kColorSpeakerName, fontSize: 20.0),
                    child: new Text(speak.name),
                  ),
                  onTap: () {
                    mSelectedSpeaker = speak;
                    Timeline.instantSync('Start Transition',
                        arguments: <String, String>{
                          'from': '/',
                          'to': SpeakerDetailsWidget.routeName
                        });
                    Navigator.pushNamed(context, SpeakerDetailsWidget.routeName);
                  })),
          new Column(children: <Widget>[
            new Container(
                margin: const EdgeInsets.only(right: kMaterialPadding),
                child: new SizedBox(
                    width: 48.0,
                    child: new CircleAvatar(
                      child: new IconButton(
                          alignment: FractionalOffset.center,
                          padding: const EdgeInsets.all(0.0),
                          onPressed: () {
                            Future<SpeakerRating> ratings = _showRatingDialog();
                            _saveRatings(ratings, mSelectedSession);
                          },
                          icon: new Icon(Icons.message, color: Colors.white),
                          color: kColorFavoriteOff),
                    ))),
          ]),
        ]);
        speakerRowWidgets.add(speakerRowWidget);
      });
    } else {
      mSelectedSession.speakers.forEach((speakerId) {
        Speaker speak = mSpeakers[speakerId.toString()];
        String speakerInitials = getCircleDetails(speak);
        Widget speakerRowWidget = new Row(children: <Widget>[
          new Expanded(
              child: new ListTile(
                  leading: new ExcludeSemantics(
                      child: new CircleAvatar(
                        child: speakerInitials.isEmpty
                            ? null
                            : new Text(speakerInitials),
                        backgroundImage: new PlutoImage.networkWithPlaceholder(
                          speak.thumbnailUrl,
                          logoImage,
                          alignment: const FractionalOffset(0.0, 0.0),
                        )
                            .image,
                      )),
                  title: new DefaultTextStyle(
                    style:
                    new TextStyle(color: kColorSpeakerName, fontSize: 20.0),
                    child: new Text(speak.name),
                  ),
                  onTap: () {
                    mSelectedSpeaker = speak;
                    Timeline.instantSync('Start Transition',
                        arguments: <String, String>{
                          'from': '/',
                          'to': SpeakerDetailsWidget.routeName
                        });
                    Navigator.pushNamed(context, SpeakerDetailsWidget.routeName);
                  })),
        ]);
        speakerRowWidgets.add(speakerRowWidget);
      });
    }


    Widget sessionDescription = new Container(
      child: new Text(mSelectedSession.description,
          style: new TextStyle(color: const Color(0xff696969), fontSize: 18.0)),
      padding: const EdgeInsets.all(kPadding),
    );

    List<Widget> sessionDetailWidgets = <Widget>[];
    sessionDetailWidgets.addAll(speakerRowWidgets);
    sessionDetailWidgets.add(sessionDescription);

    List<double> gradientStops = <double>[];
    gradientStops.add(.5);

    var roomOrTrack = "";
    if (mSelectedSession != null &&
        (mSelectedSession.room != "" && mSelectedSession.room != null)) {
      roomOrTrack = mSelectedSession.room;
    } else if (mSelectedSession != null &&
        (mSelectedSession.track != "" && mSelectedSession.track != null)) {
      roomOrTrack = mSelectedSession.track;
    }

    return new Scaffold(
      body: new CustomScrollView(
        slivers: <Widget>[
          new SliverAppBar(
            expandedHeight: 240.0,
            pinned: true,
            flexibleSpace: new FlexibleSpaceBar(
              background: new Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  new Container(
                    margin: new EdgeInsets.only(
                        left: kPadding, bottom: kPadding, top: 100.0),
                    padding: new EdgeInsets.only(right: kMaterialPadding),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text(
                          mSelectedSession.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: new TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        new Text(
                          roomAndTime(),
                          maxLines: 4,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: new TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                        ),
                        new Row(children: <Widget>[
                          new Expanded(
                              child: new Text(
                            roomOrTrack,
                            style: new TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          )),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          new SliverList(
            delegate: new SliverChildListDelegate(sessionDetailWidgets),
          ),
        ],
      ),
    );
  }
}
