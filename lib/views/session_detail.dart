// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:developer';

import 'package:devfest_florida_app/data/speaker.dart';
import 'package:devfest_florida_app/main.dart';
import 'package:devfest_florida_app/util/pluto.dart';
import 'package:devfest_florida_app/views/speaker_detail.dart';
import 'package:flutter/material.dart';

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
    if (speaker.name
        .split(' ')
        .length >= 2) {
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

  @override
  Widget build(BuildContext context) {
    List<Widget> speakerRowWidgets = <Widget>[];
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
                        onPressed: () {},
                        icon: new Icon(Icons.message, color: Colors.white),
                        color: kColorFavoriteOff),
                  )
              )
          ),
        ]),
      ]);
      speakerRowWidgets.add(speakerRowWidget);
    });

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
