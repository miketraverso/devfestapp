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
    return kSelectedSession.room
        + '\n'
        + formatter.format(kSelectedTimeSlot.startDate).replaceAll(" ", "")
        + ' - '
        + formatter.format(kSelectedTimeSlot.endDate).replaceAll(" ", "");
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

  @override
  Widget build(BuildContext context) {
    List<Widget> speakerRowWidgets = <Widget>[];
    kSelectedSession.speakers.forEach((speakerId) {
      Speaker speak = kSpeakers[speakerId.toString()];
      String speakerInitials = getCircleDetails(speak);

      Widget speakerRowWidget = new MergeSemantics(
        child: new ListTile(
          leading: new ExcludeSemantics(
              child: new CircleAvatar(
                child: speakerInitials.isEmpty ? null : new Text(speakerInitials),
                backgroundImage: new PlutoImage.networkWithPlaceholder(
                    speak.thumbnailUrl,
                    logoImage)
                    .image,
              )),
          title: new DefaultTextStyle(
            style: new TextStyle(color: kColorSpeakerName, fontSize: 20.0),
            child: new Text(speak.name),
          ),
          onTap: () {
            kSelectedSpeaker = speak;
            Timeline.instantSync('Start Transition', arguments: <String, String>{
              'from': '/',
              'to': SpeakerDetailsWidget.routeName
            });
            Navigator.pushNamed(context, SpeakerDetailsWidget.routeName);
          }
        ),
      );
      speakerRowWidgets.add(speakerRowWidget);
    });


    Widget sessionDescription = new Container(
      child: new Text(kSelectedSession.description,
          style: new TextStyle(
              color: const Color(0xff696969),
              fontSize: 18.0)
      ),
      padding: const EdgeInsets.all(kPadding),
    );

    List<Widget> sessionDetailWidgets = <Widget>[];
    sessionDetailWidgets.addAll(speakerRowWidgets);
    sessionDetailWidgets.add(sessionDescription);

    List<double> gradientStops = <double>[];
    gradientStops.add(.5);

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
                      margin: new EdgeInsets.only(left: kPadding, bottom: kPadding, top: 100.0),
                      padding: new EdgeInsets.only(right: kMaterialPadding),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                            new Text(
                              kSelectedSession.title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: new TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),
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
                              child:new Text(
                                kSelectedSession.track,
                                style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                ),
                              )
                            ),
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
