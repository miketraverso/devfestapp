// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:devfest_florida_app/main.dart';
import 'package:devfest_florida_app/util/pluto.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SpeakerDetailsWidget extends StatefulWidget {
  static const String routeName = '/speakerdetail';

  @override
  SpeakerDetailsState createState() => new SpeakerDetailsState();
}

class SpeakerDetailsState extends State<SpeakerDetailsWidget> {
  final double _appBarHeight = 256.0;

  String _twitterHandle() {
    String twitterHandle = "";
    if (kSelectedSpeaker.socialMap.containsKey("twitter")) {
      twitterHandle = kSelectedSpeaker.socialMap["twitter"];
      if (twitterHandle.startsWith("https://twitter.com/")) {
        twitterHandle = twitterHandle.replaceAll("https://twitter.com/", "@");
        return twitterHandle;
      } else if (twitterHandle.startsWith("http://twitter.com/")) {
        twitterHandle = twitterHandle.replaceAll("http://twitter.com/", "@");
        return twitterHandle;
      } else if (twitterHandle.startsWith("https://www.twitter.com/")) {
        twitterHandle = twitterHandle.replaceAll("https://www.twitter.com/", "@");
        return twitterHandle;
      } else if (twitterHandle.startsWith("http://www.twitter.com/")) {
        twitterHandle = twitterHandle.replaceAll("http://www.twitter.com/", "@");
        return twitterHandle;
      }
    }
    return twitterHandle;
  }

  @override
  Widget build(BuildContext context) {
    String twitterHandle = _twitterHandle();

    Widget twitterWidget = new Row (
      children: <Widget>[
        new IconButton(
            icon: new Icon(FontAwesomeIcons.twitter, color: const Color(0xff1DA1F2), size: 28.0,),
            onPressed: () {
              launch(kSelectedSpeaker.socialMap["twitter"]);
            }
        ),
        new Container (
          padding: new EdgeInsets.only(top: kPadding),
          child: new DefaultTextStyle(
            style: new TextStyle(color: const Color(0xff1DA1F2), fontSize: 20.0, textBaseline: TextBaseline.ideographic),
            child: new Row(children: <Widget>[
              new Text(twitterHandle),
            ])
          ),
        )
      ],
    );

    Widget _speakerName = new Container(
      child: new DefaultTextStyle(
        style: new TextStyle(color: Colors.grey[800],
            fontWeight: FontWeight.bold,
            fontSize: 26.0),
        child: new Text(kSelectedSpeaker.name),
      ),
      padding: const EdgeInsets.only(top: kPadding, left: kPadding, right: kPadding),
    );

    Widget speakerBio = new Container(
      child: new DefaultTextStyle(
          style: new TextStyle(color: const Color(0xff696969), fontSize: 18.0),
          child: new Text(kSelectedSpeaker.bio),
      ),
      padding: const EdgeInsets.all(kPadding),
    );

    List<Widget> speakerDetailWidgets = <Widget>[];
    speakerDetailWidgets.add(_speakerName);
    if (twitterHandle.isNotEmpty) {
      speakerDetailWidgets.add(twitterWidget);
    }
    speakerDetailWidgets.add(speakerBio);

    List<double> gradientStops = <double>[];
    gradientStops.add(.5);

    return new Scaffold(
        body: new CustomScrollView(
          slivers: <Widget>[
            new SliverAppBar(
              expandedHeight: _appBarHeight,
              pinned: true,
              flexibleSpace: new FlexibleSpaceBar(
                title: new Text(kSelectedSpeaker.name),
                background: new Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    new PlutoImage.networkWithPlaceholder(
                      kSelectedSpeaker.photoUrl,
                      new Image.asset('assets/images/devfest-logo.png'),
                      fit: BoxFit.cover,
                      height: _appBarHeight,
                    ),
                    const DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: const LinearGradient(
                          begin: const FractionalOffset(0.5, 0.0),
                          stops: const [0.5, 0.7, 0.85, 0.98],
                          end: const FractionalOffset(.5, 1.0),
                          colors: const <Color>[const Color(0x00000000), const Color(0x30000000), const Color(0x70000000), const Color(0xaa0c0c0c)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            new SliverList(
              delegate: new SliverChildListDelegate(speakerDetailWidgets),
            ),
          ],
        ),
    );
  }
}
