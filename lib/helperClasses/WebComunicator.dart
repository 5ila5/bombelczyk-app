import 'dart:typed_data';

import 'package:Bombelczyk/helperClasses/Akku.dart';
import 'package:Bombelczyk/helperClasses/Arbeit.dart';
import 'package:Bombelczyk/helperClasses/Aufzug.dart';
import 'package:Bombelczyk/helperClasses/Position.dart';
import 'package:Bombelczyk/helperClasses/SortTypes.dart';
import 'package:Bombelczyk/helperClasses/StorageHelper.dart';
import 'package:Bombelczyk/helperClasses/ToDo.dart';
import 'package:Bombelczyk/helperClasses/Tour.dart';
import 'package:Bombelczyk/helperClasses/TourWorkType.dart';
import 'package:Bombelczyk/helperClasses/User.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

enum RequestType {
  GET(method: http.get),
  POST(method: http.post),
  DELETE(method: http.delete),
  PATCH(method: http.patch);

  const RequestType({required this.method});
  final Function method;
}

class WebComunicater {
  final Future<String?>? _auth_token;
  static final String BASE_URL = "https://api.bombelczyk.de/UpP0UH3nFKMsnJk3/";
  static final gzip = GZipCodec();
  static WebComunicater? _instance;

  static WebComunicater get instance {
    if (_instance != null) {
      return _instance!;
    }
    throw Exception("WebComunicater not initialized");
  }

  WebComunicater(this._auth_token) {
    _instance = this;
  }

  Future<String?> requestAuthToken(String password) {
    Future<String?> token = requestWithAnalyse("login", RequestType.POST, {
      "password": password,
    }).then((value) {
      if (value is String && value.isNotEmpty) {
        return value;
      }
      return null;
    });

    _instance = WebComunicater(token);
    return token;
  }

  Future<bool> login(String password) {
    return requestAuthToken(password).then((value) {
      if (value != null) {
        StorageHelper.setAuth(value);
        _instance = WebComunicater(Future.value(value));
        return testConnection();
      }
      return false;
    });
  }

  Future<List<Aufzug>> searchAufzug(String search, Sort sort) {
    return requestWithAnalyse("aufzug/search", RequestType.GET, {
      "search": search,
      "sort_key": sort.type.name,
      "sort_order": sort.direction.name,
    }).then(
        (value) => List<Aufzug>.from(value.map((e) => Aufzug.fromApiJson(e))));
  }

  Future<List<AufzugWithDistance>> getNearbyAufzug(
      Future<Position> position, int count) {
    return position
        .then((pos) => requestWithAnalyse("aufzug/nearby", RequestType.GET, {
              "lat": pos.latitude,
              "lon": pos.longitude,
              "count": count,
            }))
        .then((value) => List<AufzugWithDistance>.from(
            value.map((e) => AufzugWithDistance.fromApiJson(
                  e,
                ))));
  }

  Future<List<Aufzug>> getHistory() async {
    List<int> afzIdxs = await StorageHelper.getHistory();
    if (afzIdxs.isEmpty) {
      return Future.value([]);
    }
    return getAfzByIdxList(afzIdxs);
  }

  Future<List<Aufzug>> getAfzByIdxList(List<int> afzIdxs) {
    Map<String, List<int>> body = {"list": afzIdxs};
    return requestWithAnalyse("aufzug/liste", RequestType.GET, body).then(
        (value) => List<Aufzug>.from(
            (value).map((value) => (Aufzug.fromApiJson(value)))));
  }

  Future<DetailedAufzug> getDetailedAufzug(Aufzug aufzug) {
    return Future.wait([getAfzWithToDosOf(aufzug), _getArbeiten(aufzug)]).then(
        (value) => DetailedAufzug.fromAufzugWithToDos(
            value[0] as AufzugWithToDos, value[1] as List<Arbeit>));
  }

  Future<bool> setToDo(ToDo toDo, {bool? done, String? text, Aufzug? afz}) {
    Map<String, dynamic> body = {};
    if (done != null) {
      body["done"] = done;
    }
    if (text != null) {
      body["text"] = text;
    }
    if (afz != null) {
      body["afzIdx"] = afz.afzIdx;
    }
    if (body.isEmpty) {
      throw Exception("setTodo: nothing to set");
    }

    return requestWithAnalyse("todo/${toDo.id}", RequestType.PATCH, body)
        .then((value) => true);
  }

  Future<ToDo> createToDo(Aufzug afz, String text, bool done) {
    return requestWithAnalyse("todo", RequestType.POST, {
      "afzIdx": afz.afzIdx,
      "text": text,
      "done": done,
    }).then((value) => ToDo(
        value['idx'] is String ? int.parse(value['idx']) : value['idx'],
        afz,
        text,
        DateTime.parse(value["created"]),
        DateTime.now()));
  }

  Future<bool> deleteToDo(ToDo todo) {
    return requestWithAnalyse("todo/${todo.id}", RequestType.DELETE).then(
      (value) => value is bool ? value : false,
    );
  }

  Future<List<AufzugWithToDos>> getToDos(
      {Sort? sort, bool? show_checked, bool? show_unchecked, String? search}) {
    Map<String, dynamic> body = {};
    if (sort != null) {
      body["sort_key"] = sort.type.name;
      body["sort_order"] = sort.direction.name;
    }
    if (show_checked != null) {
      body["show_checked"] = show_checked;
    }
    if (show_unchecked != null) {
      body["show_unchec"] = show_unchecked;
    }
    if (search != null) {
      body["search"] = search;
    }

    return requestWithAnalyse("todo", RequestType.GET, body).then((value) =>
        List<AufzugWithToDos>.from(
            value.map((e) => AufzugWithToDos.fromApiJson(e))));
  }

  Future<AufzugWithToDos> getAfzWithToDosOf(Aufzug afz) {
    return getToDosOfAfz(afz)
        .then((value) => AufzugWithToDos.fromAufzug(afz, value));
  }

  Future<List<ToDo>> getToDosOfAfz(Aufzug afz) {
    return requestWithAnalyse("aufzug/${afz.afzIdx}/todos", RequestType.GET)
        .then((value) =>
            List<ToDo>.from(value.map((e) => ToDo.fromApiJson(e, afz))));
  }

  Future<List<Akku>> getAkkus(Aufzug afz) {
    return requestWithAnalyse("aufzug/${afz.afzIdx}/akkus", RequestType.GET)
        .then((value) =>
            List<Akku>.from(value.map((e) => Akku.fromApiJson(e, afz))));
  }

  Future<List<TourWorkType>> getTourWorkTypes() {
    return requestWithAnalyse("tour/types", RequestType.GET).then((value) =>
        List<TourWorkType>.from((value).map(
            (key, value) => (TourWorkType(int.parse(key.toString()), value)))));
  }

  Future<List<Tour>> getTours({DateTime? from, DateTime? to}) {
    Map<String, dynamic> body = {};
    if (from != null) {
      body["from"] = from.toIso8601String().substring(0, 10);
    }
    if (to != null) {
      body["to"] = to.toIso8601String().substring(0, 10);
    }

    Future<dynamic> tours = requestWithAnalyse("tour", RequestType.GET, body);
    Future<List<TourWorkType>> workTypes = TourWorkTypes.getTypes();

    return Future.wait([tours, workTypes]).then((value) =>
        List<Tour>.from(value[0].map((e) => Tour.fromApiJson(e, value[1]))));
  }

  Future<List<MemoryImage>> getTourAfzImages(Tour tour, Aufzug afz) {
    return requestWithAnalyse("aufzug/${afz.afzIdx}/images", RequestType.GET)
        .then((value) => List<MemoryImage>.from(
            value.map((e) => MemoryImage(Uint8List.fromList(e)))));
  }

  Future<bool> deleteTour(Tour tour) {
    return requestWithAnalyse("tour/${tour.idx}", RequestType.DELETE)
        .then((value) => value is bool ? value : false);
  }

  Future<bool> deleteAfzFromTour(Tour tour, Aufzug afz) {
    return requestWithAnalyse(
            "tour/${tour.idx}/afz/${afz.afzIdx}", RequestType.DELETE)
        .then((value) => value is bool ? value : false);
  }

  Future<bool> tourModifyAfz(Tour tour, Aufzug afz,
      {bool? done, MoveDirection? dir}) {
    Map<String, dynamic> body = {};
    if (done != null) {
      body["done"] = done;
    }
    if (dir != null) {
      body["dir"] = dir.name;
    }

    if (body.isEmpty) {
      throw Exception("tourModifyAfz: nothing to set");
    }

    return requestWithAnalyse(
            "tour/${tour.idx}/afz/${afz.afzIdx}", RequestType.PATCH, body)
        .then((value) => value is bool ? value : false);
  }

  Future<bool> modifyTour(Tour tour,
      {String? name,
      DateTime? date,
      List<User>? share,
      List<TourAufzug>? afzs}) {
    Map<String, dynamic> body = {};
    if (name != null) {
      body["text"] = name;
    }
    if (date != null) {
      // Date without Time
      body["date"] = date.toIso8601String().substring(0, 10);
    }
    if (share != null) {
      body["share"] = share.map((e) => e.id).toList();
    }
    if (afzs != null) {
      body["afzs"] = afzs.map((e) => {e.afzIdx: e.workType.idx}).toList();
    }

    if (body.isEmpty) {
      throw Exception("modifyTour: nothing to set");
    }

    return requestWithAnalyse("tour/${tour.idx}", RequestType.PATCH, body)
        .then((value) => value is bool ? value : false);
  }

  Future<Tour> createTourByTour(Tour t) {
    return createTour(t.name, t.date, t.sharedWith, t.aufzuege);
  }

  Future<Tour> createTour(
      String name, DateTime date, List<User> share, List<TourAufzug> afzs) {
    return requestWithAnalyse("tour", RequestType.POST, {
      "name": name,
      "date": date.toIso8601String().substring(0, 10),
      "share": share.map((e) => e.id).toList(),
      "afzs": afzs.map((e) => {e.afzIdx: e.workType.idx}).toList(),
    }).then((value) => Tour(
        value['idx'] is String ? int.parse(value['idx']) : value['idx'],
        name,
        date,
        aufzuege: afzs));
  }

  Future<bool> tourAddAfz(Tour tour, TourAufzug afz, TourWorkType workType) {
    return requestWithAnalyse("tour/${tour.idx}/afz", RequestType.POST, {
      "afzIdx": afz.afzIdx,
      "art": workType.idx,
    }).then((value) => value is bool ? value : false);
  }

  Future<List<User>> getUsers() {
    return requestWithAnalyse("user", RequestType.GET).then((value) =>
        List<User>.from(value.map((key, value) =>
            User(key is String ? int.parse(key) : key, value))));
  }

  Future<List<Arbeit>> _getArbeiten(Aufzug afz) {
    return requestWithAnalyse(
            "aufzug/${afz.afzIdx}/task-history", RequestType.GET)
        .then((value) =>
            List<Arbeit>.from(value.map((e) => Arbeit.fromApiJson(e))));
  }

  Future<dynamic> requestWithAnalyse(String path, RequestType rType,
      [Map<String, dynamic>? body]) {
    return _sendRequest(path, rType, body).then((value) {
      Map<String, dynamic> total_response = jsonDecode(value.body);
      if (!kReleaseMode) {
        if (total_response.containsKey("exceptions")) {
          print("Requesting with exceptions: " +
              total_response["exceptions"] +
              ", on: " +
              path +
              ", body: " +
              body.toString());
        }
        if (total_response.containsKey("errors")) {
          print("Requesting with errors: " +
              total_response["errors"] +
              ", on: " +
              path +
              ", body: " +
              body.toString());
        }
      }

      if (total_response["status"] == "success") {
        return total_response["content"];
      } else {
        throw Exception(total_response["message"]);
      }
    });
  }

  Future<http.Response> _sendRequest(String path, RequestType rType,
      [Map<String, dynamic>? body, bool login = false]) async {
    body ??= {};
    if ((_auth_token == null || (await _auth_token) == null) && !login) {
      throw Exception("notLoggedIn");
    }
    if (!login) {
      body.addAll({'auth': await _auth_token!});
    }
    List<int> compressedBody = gzip.encode(jsonEncode(body).codeUnits);

    return rType.method(
      Uri.https(BASE_URL + path),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Content-Encoding": "gzip",
      },
      body: compressedBody, //.codeUnits),
    );
  }

  Future<bool> testConnection() {
    return _sendRequest("auth", RequestType.GET).then((value) {
      if (value.statusCode == 200) {
        return true;
      }
      return false;
    });
  }
}
