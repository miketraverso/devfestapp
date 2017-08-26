import 'dart:collection';

class Speaker {
  String id;
  String bio;
  String company;
  String name;
  String lastName;
  String jobTitle;
  String thumbnailUrl = "";
  bool featured;

  LinkedHashMap<String, String> socialMap = new LinkedHashMap<String, String>();

  Speaker.loadFromFireBase(String fbKey, LinkedHashMap map) {
    id = fbKey;
    for (String key in map.keys) {
      switch (key) {
        case 'id':
          this.id = map[key];
          break;
        case 'bio':
          this.bio = map[key];
          break;
        case 'company':
          this.company = map[key];
          break;
        case 'name':
          this.name = map[key];
          break;
        case 'lastname':
          this.lastName = map[key];
          break;
        case 'thumbnailUrl':
          this.thumbnailUrl = map[key];
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
//              LinkedHashMap socialMap = map[key];
//              socialMap.forEach((key, value) {
//                socials.add(new Social(key, value));
//              });
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
