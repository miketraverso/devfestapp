// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:devfest_florida_app/util/pluto.dart';
import 'package:devfest_florida_app/views/shared/drawer.dart';
import 'package:devfest_florida_app/main.dart';
import 'package:flutter/material.dart';

class LocationWidget extends StatefulWidget {
  const LocationWidget({Key key}) : super(key: key);

  static const routeName = '/location';

  @override
  _LocationState createState() => new _LocationState();
}

class _LocationState extends State<LocationWidget> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text(
        kAppTitle,
        style: new TextStyle(color: Colors.white, fontSize: 24.0),
      )),
      drawer: new ConfAppDrawer(),
      body: new Container(
          margin: const EdgeInsets.all(kPadding),
          child: new Column(
            children: <Widget>[
              new Row(children: <Widget>[
                new Expanded(
                  child: new Text(
                    kVenueName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: new TextStyle(
                        fontSize: 22.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ]),
              new Padding(padding: const EdgeInsets.only(bottom: kPadding)),
              new Row(
                children: <Widget>[
                  new Text(
                    kVenueAddress,
                    style: new TextStyle(
                      color: kColorText,
                      fontSize: 18.0,
                    ),
                  ),
                ],
              ),
              new Padding(padding: const EdgeInsets.only(bottom: kPadding)),
              new Row(
                children: <Widget>[
                  new Text(
                    kVenuePhone,
                    style: new TextStyle(
                      color: kColorText,
                      fontSize: 18.0,
                    ),
                  ),
                ],
              ),
              new Padding(padding: const EdgeInsets.only(bottom: kPadding)),
                new Expanded(
                  child: new PlutoImage.networkWithPlaceholder(
                      kGoogleStaticMapUrl,
                      new Image.asset('assets/images/devfest-logo.png'),
                  fit: BoxFit.fitHeight),
                ),
            ],
          )
      ),
    );
  }
}
