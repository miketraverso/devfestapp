// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:developer';
import 'package:devfest_florida_app/data/speaker.dart';
import 'package:devfest_florida_app/util/pluto.dart';
import 'package:devfest_florida_app/views/shared/drawer.dart';
import 'package:devfest_florida_app/main.dart';
import 'package:devfest_florida_app/views/speaker_detail.dart';
import 'package:flutter/material.dart';

class SpeakerListWidget extends StatefulWidget {
  const SpeakerListWidget({Key key}) : super(key: key);

  static const String routeName = '/speakers';

  @override
  _SpeakerListState createState() => new _SpeakerListState();
}

class _SpeakerListState extends State<SpeakerListWidget> {
  Widget buildListTile(BuildContext context, Speaker speaker) {
    String speakerInitials = getCircleDetails(speaker);
    return new MergeSemantics(
      child: new ListTile(
        leading: new ExcludeSemantics(
            child: new CircleAvatar(
          child: speakerInitials.isEmpty ? null : new Text(speakerInitials),
          backgroundImage: new PlutoImage.networkWithPlaceholder(
                  speaker.photoUrl,
                  new Image.asset('assets/images/devfest-logo.png'))
              .image,
        )),
        title: new Text(speaker.name),
        onTap: () {
          kSelectedSpeaker = speaker;
          Timeline.instantSync('Start Transition', arguments: <String, String>{
            'from': '/',
            'to': SpeakerDetailsWidget.routeName
          });
          Navigator.pushNamed(context, SpeakerDetailsWidget.routeName);
        },
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
    kSpeakers.values.forEach((speaker) {
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
      appBar: new AppBar(
          title: new Text(
        kAppTitle,
        style: new TextStyle(color: Colors.white, fontSize: 24.0),
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

    if (speaker.photoUrl.isEmpty ||
        !(speaker.photoUrl.endsWith("jpg") ||
            speaker.photoUrl.endsWith("jpeg") ||
            speaker.photoUrl.endsWith("png"))) {
      return speakerIntials;
    } else
      return "";
  }
}
