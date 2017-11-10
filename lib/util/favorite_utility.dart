import 'dart:async';

import 'package:devfest_florida_app/data/session.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FavoriteUtility {

  static Future<bool> isFavorite(Session session) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteSessions = prefs.getStringList("favoriteSessions");
    if (favoriteSessions == null) {
      return false;
    }
    if (favoriteSessions.contains(session.sessionId.toString())) {
      return true;
    }
    return false;
  }
}