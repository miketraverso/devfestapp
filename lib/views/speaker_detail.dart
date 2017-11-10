// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:devfest_florida_app/main.dart';
import 'package:devfest_florida_app/util/pluto.dart';
import 'package:devfest_florida_app/views/shared/drawer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SpeakerDetailsWidget extends StatefulWidget {
  static const routeName = '/speakerdetail';

  @override
  SpeakerDetailsState createState() => new SpeakerDetailsState();
}

class SpeakerDetailsState extends State<SpeakerDetailsWidget> {
  final _appBarHeight = 256.0;

  String _twitterHandle() {
    var twitterHandle = "";
    if (kSelectedSpeaker.socialMap.containsKey("twitter")) {
      twitterHandle = kSelectedSpeaker.socialMap["twitter"];
      if (twitterHandle.startsWith("https://twitter.com/")) {
        twitterHandle = twitterHandle.replaceAll("https://twitter.com/", "@");
        return twitterHandle;
      } else if (twitterHandle.startsWith("http://twitter.com/")) {
        twitterHandle = twitterHandle.replaceAll("http://twitter.com/", "@");
        return twitterHandle;
      } else if (twitterHandle.startsWith("https://www.twitter.com/")) {
        twitterHandle =
            twitterHandle.replaceAll("https://www.twitter.com/", "@");
        return twitterHandle;
      } else if (twitterHandle.startsWith("http://www.twitter.com/")) {
        twitterHandle =
            twitterHandle.replaceAll("http://www.twitter.com/", "@");
        return twitterHandle;
      }
    }
    return twitterHandle;
  }

  @override
  Widget build(BuildContext context) {
    var twitterHandle = _twitterHandle();

    Widget twitterWidget = new Container(
      margin: new EdgeInsets.only(left: kPadding, top: kPadding),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              new Row(children: <Widget>[
                new Expanded(
                  child: new Row(
                    children: <Widget>[
                      new IconButton(
                          icon: new Icon(
                            FontAwesomeIcons.twitter,
                            color: const Color(0xff1DA1F2),
                            size: 28.0,
                          ),
                          onPressed: () {
                            launch(kSelectedSpeaker.socialMap["twitter"]);
                          }),
                      new Padding(
                          padding: new EdgeInsets.only(top: defaultTargetPlatform == TargetPlatform.iOS ? 4.0 : 0.0),
                          child: new RichText(
                              text: new TextSpan(children: <TextSpan>[
                            new LinkTextSpan(
                                style: new TextStyle(
                                    color: const Color(0xff1DA1F2),
                                    fontSize: 20.0),
                                url: kSelectedSpeaker.socialMap["twitter"],
                                text: twitterHandle),
                          ]))),
                    ],
                  ),
                )
              ]),
            ]),
        ],
      ),
    );

    Widget speakerBio = new Container(
      child: new Text(kSelectedSpeaker.bio,
          style: new TextStyle(
              color: const Color(0xff696969),
              fontSize: 18.0)
      ),
      padding: const EdgeInsets.all(kPadding),
    );

    List<Widget> speakerDetailWidgets = <Widget>[];
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
              title: new Text(kSelectedSpeaker.name, textAlign: TextAlign.center,),
              background: new Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  new PlutoImage.networkWithPlaceholder(
                    kSelectedSpeaker.thumbnailUrl,
                    logoImage,
                    fit: BoxFit.fitWidth,
                    alignment: const FractionalOffset(0.5, 0.5),
                    height: _appBarHeight,
                  ),
                  const DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: const LinearGradient(
                        begin: const FractionalOffset(0.5, 0.0),
                        stops: const [0.5, 0.7, 0.8, 0.86],
                        end: const FractionalOffset(.5, 1.0),
                        colors: const <Color>[
                          const Color(0x00000000),
                          const Color(0x99000000),
                          const Color(0xbb000000),
                          const Color(0xdd0c0c0c)
                        ],
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
