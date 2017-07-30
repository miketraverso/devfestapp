// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:devfest_florida_app/data/speaker.dart';
import 'package:devfest_florida_app/main.dart';
import 'package:devfest_florida_app/util/pluto.dart';
import 'package:flutter/material.dart';

class SessionDetailsWidget extends StatefulWidget {
  static const String routeName = '/sessiondetails';

  @override
  SessionDetailsState createState() => new SessionDetailsState();
}

class SessionDetailsState extends State<SessionDetailsWidget> {

  String roomAndTime() {
    return kSelectedSession.room + '\n' + kSelectedTimeslot.starts + ' - ' + kSelectedTimeslot.ends;
  }

  String getCircleDetails(Speaker speaker) {
    String speakerIntials;
    if (speaker.name.split(' ').length >= 2) {
      speakerIntials = speaker.name.split(' ')[0].substring(0, 1) +
          speaker.name.split(' ')[1].substring(0, 1);
    } else {
      speakerIntials = speaker.name.substring(0, 1);
    }

    if (speaker.photoUrl.isEmpty ||
        !(speaker.photoUrl.endsWith("jpg") ||
            speaker.photoUrl.endsWith("jpeg") ||
            speaker.photoUrl.endsWith("png"))) {
      return speakerIntials;
    } else
      return "";
  }

  @override
  Widget build(BuildContext context) {
    Widget sessionTitle = new Container(
      child: new DefaultTextStyle(
        style: new TextStyle(color: Colors.grey[800],
            fontWeight: FontWeight.bold,
            fontSize: 26.0),
        child: new Text(kSelectedSession.title),
      ),
      padding: const EdgeInsets.only(top: kPadding, left: kPadding, right: kPadding),
    );


//    Speaker speak = kSpeakers[kSelectedSession.speakers[0].toString()];
//    String speakerInitials = getCircleDetails(speak);

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
                    speak.photoUrl,
                    new Image.asset('assets/images/devfest-logo.png'))
                    .image,
              )),
          title: new Text(speak.name),
        ),
      );
      speakerRowWidgets.add(speakerRowWidget);
    });


    Widget sessionDescription = new Container(
      child: new DefaultTextStyle(
          style: new TextStyle(color: const Color(0xff696969), fontSize: 15.0, ),
          child: new Text(kSelectedSession.description),
      ),
      padding: const EdgeInsets.all(kPadding),
    );

    List<Widget> sessionDetailWidgets = <Widget>[];
//    sessionDetailWidgets.add(sessionTitle);
    sessionDetailWidgets.addAll(speakerRowWidgets);
    sessionDetailWidgets.add(sessionDescription);

    List<double> gradientStops = <double>[];
    gradientStops.add(.5);

    return new Scaffold(
        body: new CustomScrollView(
          slivers: <Widget>[
            new SliverAppBar(
              expandedHeight: 220.0,
              pinned: true,
              flexibleSpace: new FlexibleSpaceBar(
                background: new Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                      new Container(
                        margin: new EdgeInsets.only(left: kPadding, bottom: kPadding, top: 100.0),
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Row(children: <Widget>[
                              new Expanded(
                                child: new Text(
                                  kSelectedSession.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: new TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            ]),
                            new Row(
                              children: <Widget>[
                                new Text(
                                  roomAndTime(),
                                  style: new TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ],
                            ),
                            new Row(children: <Widget>[
                              new Expanded(
                                child: new Row(
                                  children: <Widget>[
                                    new Text(
                                      kSelectedSession.track,
                                      style: new TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
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
//      ),
    );
  }
}
