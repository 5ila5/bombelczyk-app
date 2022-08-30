import 'dart:convert';

import 'web_comunicater.dart';
import 'package:flutter/foundation.dart';

class TourGeneralInfo {
  static TourGeneralInfo? _instance;
  Map<int, String> personen = {};
  Map<int, String> arbeitsarten = {};

  List<String> getArbeitsArtStringList() {
    List<String> toReturn = [];
    arbeitsarten.forEach((key, value) => toReturn.add(value));
    return toReturn;
  }

  Future<void> request() async {
    String response = await WebComunicater.sendRequest(<String, String>{
      "get_general_tour_stuff": "1",
      if (kDebugMode) "debug": "1"
    });

    Map<String, Map<dynamic, dynamic>> json =
        Map<String, Map<dynamic, dynamic>>.from(jsonDecode(response));
    personen = json["pers"]!.map((key, value) =>
        MapEntry<int, String>(int.parse(key), value.toString()));
    arbeitsarten = json["art"]!.map((key, value) =>
        MapEntry<int, String>(int.parse(key), value.toString()));
  }

  TourGeneralInfo() {
    request();
  }

  static TourGeneralInfo getInstance() {
    if (_instance == null) {
      _instance = new TourGeneralInfo();
    }

    return _instance!;
  }

  int getArbeitsIdx(String arbeit) {
    return arbeitsarten.keys
        .firstWhere((k) => arbeitsarten[k] == arbeit, orElse: () => 0);
  }
}
