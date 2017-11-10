import 'dart:collection';

final String tableRatings = "ratings";
final String columnId = "_id";
final String columnOverall = "overall";
final String columnTechnical = "technical";
final String columnPresentation = "presentation";

class SpeakerRating {
  int id;
  int overAllRating = 0;
  int technicalRating = 0;
  int presentationRating = 0;

  SpeakerRating({
    this.overAllRating = 0,
    this.technicalRating = 0,
    this.presentationRating = 0});

  SpeakerRating.loadFromFireBase(LinkedHashMap map) {
    for (String key in map.keys) {
      switch (key) {
        case 'overall':
          this.overAllRating = map[key];
          break;
        case 'technical':
          this.technicalRating = map[key];
          break;
        case 'presentation':
          this.presentationRating = map[key];
          break;
        default:
          break;
      }
    }
  }
}