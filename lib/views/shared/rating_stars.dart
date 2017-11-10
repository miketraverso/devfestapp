import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef void RatingChangeCallback(int rating);

class StarRating extends StatelessWidget {

  int starCount;
  int rating;
  final RatingChangeCallback onRatingChanged;
  final Color color;

  StarRating(
      {this.starCount = 5, this.rating = 1, this.onRatingChanged, this.color});

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index.toDouble() >= rating) {
      icon = new Icon(
        Icons.star_border,
        size: 45.0,
        color: Theme.of(context).buttonColor,
      );
    } else if (index.toDouble() > rating - 1 && index.toDouble() < rating) {
      icon = new Icon(
        Icons.star_half,
        size: 45.0,
        color: color ?? Theme.of(context).primaryColor,
      );
    } else {
      icon = new Icon(
        Icons.star,
        size: 45.0,
        color: color ?? Theme.of(context).primaryColor,
      );
    }

    return new InkResponse(
        child:
            new GestureDetector(
      onTapUp: (TapUpDetails details) {
        onRatingChanged(index + 1);
      },
      child: icon
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
        children:
            new List.generate(starCount, (index) => buildStar(context, index)));
  }
}
