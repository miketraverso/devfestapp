// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:developer';

import 'package:devfest_florida_app/data/speaker.dart';
import 'package:devfest_florida_app/main.dart';
import 'package:devfest_florida_app/util/pluto.dart';
import 'package:devfest_florida_app/views/shared/drawer.dart';
import 'package:devfest_florida_app/views/speaker_detail.dart';
import 'package:flutter/material.dart';

class SpeakerListWidget extends StatefulWidget {
  const SpeakerListWidget({Key key}) : super(key: key);

  static const String routeName = '/speakers';

  @override
  _SpeakerListState createState() => new _SpeakerListState();
}

class _SpeakerListState extends State<SpeakerListWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget buildListTile(BuildContext context, Speaker speaker) {
    String speakerInitials = getCircleDetails(speaker);
    return new Container(
      padding: new EdgeInsets.only(top: 5.0, bottom: 5.0),
    child: new MergeSemantics(
      child: new ListTile(
        leading: new ExcludeSemantics(
            child: new CircleAvatar(
          child: speakerInitials.isEmpty ? null : new Text(speakerInitials),
          backgroundImage: new PlutoImage.networkWithPlaceholder(
                  speaker.thumbnailUrl,
                  logoImage,
                alignment: const FractionalOffset(0.5, 0.5),)
            .image,
        )),
        title: new DefaultTextStyle(
          style: new TextStyle(color: kColorSpeakerName, fontSize: 20.0),
          child: new Text(speaker.name),
        ),
        onTap: () {
          kSelectedSpeaker = speaker;
          Timeline.instantSync('Start Transition', arguments: <String, String>{
            'from': '/',
            'to': SpeakerDetailsWidget.routeName
          });
          Navigator.pushNamed(context, SpeakerDetailsWidget.routeName);
        },
      )
    ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listTiles = <Widget>[];
    var speakers = kSpeakers.values.toList();
    speakers.sort((Speaker a, Speaker b) => a.lastName.compareTo(b.lastName));
    speakers.forEach((speaker) {
      Widget listItem = buildListTile(context, speaker);
      if (listItem != null) {
        listTiles.add(listItem);
        listTiles.add(
          new Divider(
            color: kColorDivider,
            height: 0.4,
          ),
        );
      }
    });

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
          title: new Text(
            kAppTitle,
            style: navbarFontStyle,
          )),
      drawer: new ConfAppDrawer(),
      body: new Scrollbar(
        child: new ListView(
            padding: new EdgeInsets.symmetric(vertical: 8.0),
            children: listTiles),
      ),
    );
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
    } else
      return "";
  }
}
