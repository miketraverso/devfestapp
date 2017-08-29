import 'dart:collection';

import 'package:devfest_florida_app/main.dart';

class Speaker {
  String id;
  String bio;
  String company;
  String name;
  String lastName;
  String jobTitle;
  String thumbnailUrl = "";
  String photoUrl = "";
  bool featured;

  LinkedHashMap<String, String> socialMap = new LinkedHashMap<String, String>();

  Speaker.loadFromFireBase(String fbKey, LinkedHashMap map) {
    id = fbKey;
    for (String key in map.keys) {
      switch (key) {
        case 'id':
          this.id = map[key].toString();
          break;
        case 'bio':
          this.bio = map[key];
          break;
        case 'company':
          this.company = map[key];
          break;
        case 'name':
          this.name = map[key];
          if (this.name != null && this.name != "" && this.name.contains(" ")) {
            this.lastName = this.name.substring(this.name.lastIndexOf(" "));
          }
          break;
        case 'lastname':
          this.lastName = map[key];
          break;
        case 'thumbnailUrl':
          this.thumbnailUrl = map[key];
          break;
        case 'photoUrl':
          this.photoUrl = map[key];
          if (!this.photoUrl.startsWith("https://")
              || !this.photoUrl.startsWith("http://")) {
            this.photoUrl = baseUrl + this.photoUrl;
          }
          this.thumbnailUrl = this.photoUrl;
          break;
        case 'jobTitle':
          this.jobTitle = map[key];
          break;
        case 'featured':
          this.featured = map[key];
          break;
        case 'social': {
            if (map[key] is HashMap) {
              this.socialMap = map[key];
            }
          }
          break;
        default:
          break;
      }
    }
  }
}

class Social {
  String platform;
  String url;
  Social (this.platform, this.url);
}
