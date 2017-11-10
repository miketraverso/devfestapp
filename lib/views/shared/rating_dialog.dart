import 'package:devfest_florida_app/data/rating.dart';
import 'package:devfest_florida_app/views/shared/rating_stars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class StarRatingDialog extends StatefulWidget {
  SpeakerRating rating;

  StarRatingDialog({this.rating});

  @override
  _StarRatingDialogState createState() => new _StarRatingDialogState(
      overAllRating: this.rating.overAllRating,
      presentationRating: this.rating.presentationRating,
      technicalRating: this.rating.technicalRating);
}

class _StarRatingDialogState extends State<StarRatingDialog> {
  int overAllRating = 0;
  int technicalRating = 0;
  int presentationRating = 0;

  _StarRatingDialogState(
      {this.overAllRating, this.technicalRating, this.presentationRating});

  @override
  Widget build(BuildContext context) {
    const topPadding = 8.0;
    return new AlertDialog(
      title: new Text(
        'Rate this session',
        style: new TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: new SizedBox(
          height: 320.0,
          child: new Column(children: <Widget>[
            buildOverallLabel(),
            buildOverallRating(),
            new Padding(
                padding: const EdgeInsets.fromLTRB(.0, topPadding, .0, .0)),
            buildTechnicalLabel(),
            buildTechnicalRating(),
            new Padding(
                padding: const EdgeInsets.fromLTRB(.0, topPadding, .0, .0)),
            buildPresentationLabel(),
            buildPresentationRating()
          ])),
      actions: <Widget>[
        new FlatButton(
          child: new Text('Cancel',
            style: new TextStyle(
              fontSize: 18.0,
              color: Colors.red
            )),
          onPressed: () {
            Navigator.of(context).pop(context);
          },
        ),
        new FlatButton(
          child: new Text('Submit rating',
            style: new TextStyle(
              fontSize: 18.0,
                color: const Color.fromARGB(255, 100, 100, 100)
            )),
          onPressed: () {
            Navigator.pop(
                context,
                new SpeakerRating(
                    overAllRating: overAllRating,
                    technicalRating: technicalRating,
                    presentationRating: presentationRating));
          },
        ),
      ],
    );
  }

  Widget buildOverallRating() {
    return new Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              new Container(
                margin: const EdgeInsets.only(top: 8.0),
                child: new StarRating(
                  rating: overAllRating,
                  onRatingChanged: (overAllRating) {
                    setState(() {
                      this.overAllRating = overAllRating;
                    });
                  },
                ),
              )
            ],
          ),
        ]);
  }

  Widget buildPresentationRating() {
    return new Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              new Container(
                margin: const EdgeInsets.only(top: 8.0),
                child: new StarRating(
                  rating: presentationRating,
                  onRatingChanged: (presentationRating) {
                    setState(() {
                      this.presentationRating = presentationRating;
                    });
                  },
                ),
              )
            ],
          ),
        ]);
  }

  Widget buildTechnicalRating() {
    return new Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              new Container(
                margin: const EdgeInsets.only(top: 8.0),
                child: new StarRating(
                  rating: technicalRating,
                  onRatingChanged: (technicalRating) => setState(() {
                        this.technicalRating = technicalRating;
                      }),
                ),
              )
            ],
          ),
        ]);
  }

  Widget buildOverallLabel() {
    return new Row(
      children: <Widget>[
        new Expanded(
          child: new Text(
            'Overall session experience:',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: new TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPresentationLabel() {
    return new Row(
      children: <Widget>[
        new Expanded(
          child: new Text(
            'Presentation skills of the speaker:',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: new TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTechnicalLabel() {
    return new Row(
      children: <Widget>[
        new Expanded(
          child: new Text(
            'Technical level of the session content:',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: new TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
      ],
    );
  }
}
