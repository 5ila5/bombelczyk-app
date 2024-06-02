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

class WrongAuthException implements Exception {
  final String message;
  WrongAuthException(this.message);
}

class NoAuthException extends WrongAuthException {
  NoAuthException() : super("No Auth Token");
}

class RequestSettings {
  RequestSettings._();
  static const String DOMAIN = "bombelczyk-aufzuege.de";
  static final String BASE_PATH = "UpP0UH3nFKMsnJk3/";
  static final gzip = GZipCodec();
}

enum RequestType {
  GET(method: _get),
  POST(method: _post),
  DELETE(method: _delete),
  PATCH(method: _patch);

  const RequestType({required this.method});
  final Future<http.Response> Function(String, Map<String, dynamic>?,
      {Map<String, String>? headers}) method;

  static Uri _uri(String path) =>
      Uri.https(RequestSettings.DOMAIN, RequestSettings.BASE_PATH + path);

  static Uri _getUri(String path, Map<String, dynamic>? body) {
    print(body);
    return Uri.https(
        RequestSettings.DOMAIN, RequestSettings.BASE_PATH + path, body);
  }

  static List<int> cBody(Map<String, dynamic>? body) =>
      RequestSettings.gzip.encode(jsonEncode(body).codeUnits);

  static Future<http.Response> _get(String path, Map<String, dynamic>? body,
      {Map<String, String>? headers}) {
    Uri uri = _getUri(path, body);

    print("URI: " + uri.toString());
    return http.get(uri, headers: headers);
  }

  static Future<http.Response> _post(String path, Map<String, dynamic>? body,
      {Map<String, String>? headers}) {
    return http.post(_uri(path), body: cBody(body), headers: headers);
  }

  static Future<http.Response> _delete(String path, Map<String, dynamic>? body,
      {Map<String, String>? headers}) {
    return http.delete(_uri(path), body: cBody(body), headers: headers);
  }

  static Future<http.Response> _patch(String path, Map<String, dynamic>? body,
      {Map<String, String>? headers}) {
    return http.patch(_uri(path), body: cBody(body), headers: headers);
  }
}

class WebComunicaterMock extends WebComunicater {
  WebComunicaterMock() : super(Future.value("mock"));

  @override
  Future<String?> requestAuthToken(String password) {
    return Future.value("mock");
  }
}

class WebComunicater {
  final Future<String?>? _auth_token;
  static final String DOMAIN = "bombelczyk-aufzuege.de";
  static final String BASE_PATH = "UpP0UH3nFKMsnJk3/";
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
    Future<String?> token = requestWithAnalyse(
            "login", RequestType.POST, {"password": password}, true)
        .then((value) {
      print("requestAuthToken:");
      print(value);
      if (value is String && value.isNotEmpty) {
        return value;
      }
      return null;
    }).catchError((error, stackTrace) {
      // Print full error message:
      print("requestAuthToken error: " + error.toString());
      // print stacktrace:

      return null;
    });

    _instance = WebComunicater(token);
    return token;
  }

  Future<bool> login(String password) {
    Future<String?> token = requestAuthToken(password); //test
    // .catchError(//test
    //     (error, stackTrace) => null //test
    //     );
    _instance = WebComunicater(token);

    return token.then((value) {
      if (value != null) {
        StorageHelper.setAuth(value);
        _instance = WebComunicater(Future.value(value));
        return _instance!.testConnection();
      }
      return false;
    });
  }

  Future<List<Aufzug>> searchAufzug(String search, Sort sort) {
    return requestWithAnalyse("aufzug", RequestType.GET, {
      "search": search,
      "sort_key": sort.type.name,
      "sort_dir": sort.direction.name,
    }).then(
        (value) => List<Aufzug>.from(value.map((e) => Aufzug.fromApiJson(e))));
  }

  Future<List<AufzugWithDistance>> getNearbyAufzug(
      Future<Position> position, int count) {
    return position
        .then((pos) => requestWithAnalyse("aufzug/nearby", RequestType.GET, {
              "lat": pos.latitude.toString(),
              "lon": pos.longitude.toString(),
              "count": count.toString(),
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
    Map<String, List<String>> body = {
      "list[]": afzIdxs.map((e) => e.toString()).toList()
    };
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
      body["sort_dir"] = sort.direction.name;
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
    return requestWithAnalyse("aufzug/${afz.afzIdx}/akku", RequestType.GET)
        .then((value) =>
            List<Akku>.from(value.map((e) => Akku.fromApiJson(e, afz))));
  }

  Future<List<TourWorkType>> getTourWorkTypes() {
    return requestWithAnalyse("tour/types", RequestType.GET).then((value) =>
        List<TourWorkType>.from((value)
            .map((key, value) =>
                MapEntry(key, TourWorkType(int.parse(key.toString()), value)))
            .values
            .toList()));
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
            "tour/${tour.idx}/aufzug/${afz.afzIdx}", RequestType.DELETE)
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
            "tour/${tour.idx}/aufzug/${afz.afzIdx}", RequestType.PATCH, body)
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
      body["afzs"] = Map<String, int>.fromIterable(afzs,
          key: (e) => (e as TourAufzug).afzIdx.toString(),
          value: (e) => (e as TourAufzug).workType.idx);
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

  Future<Tour> createTour(String name, DateTime date, List<User> share,
      List<TourAufzug> afzs) async {
    return requestWithAnalyse("tour", RequestType.POST, {
      "text": name,
      "date": date.toIso8601String().substring(0, 10),
      "share": share.map<int>((e) => e.id).toList(),
      "afzs": Map<String, int>.fromIterable(afzs,
          key: (e) => e.afzIdx.toString(), value: (e) => e.workType.idx),
    }).then((value) => Tour(
        value is String ? int.parse(value) : value, name, date,
        aufzuege: afzs));
  }

  Future<bool> tourAddAfz(Tour tour, TourAufzug afz, TourWorkType workType) {
    return requestWithAnalyse("tour/${tour.idx}/aufzug", RequestType.POST, {
      "afzIdx": afz.afzIdx,
      "art": workType.idx,
    }).then((value) => value is bool ? value : false);
  }

  Future<List<User>> getUsers() {
    return requestWithAnalyse("tour/persons", RequestType.GET).then((value) =>
        List<User>.from((value as Map)
            .map((key, value) => MapEntry(
                key, User(key is String ? int.parse(key) : key, value)))
            .values
            .toList()));
  }

  Future<List<Arbeit>> _getArbeiten(Aufzug afz) {
    return requestWithAnalyse(
            "aufzug/${afz.afzIdx}/task-history", RequestType.GET)
        .then((value) =>
            List<Arbeit>.from(value.map((e) => Arbeit.fromApiJson(e))));
  }

  Future<dynamic> requestWithAnalyse(String path, RequestType rType,
      [Map<String, dynamic>? body, bool login = false]) {
    return _sendRequest(path, rType, body, login).then((value) {
      print(value);
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
              total_response["errors"].toString() +
              ", on: " +
              path +
              ", body: " +
              body.toString());
        }
      }

      if (total_response["status"] == "ok" ||
          total_response["status"] == "success") {
        //to json
        print(jsonEncode(total_response["content"]));
        return total_response["content"];
      } else {
        if (total_response["message"] == "invalid authentication token") {
          print("Invalid Auth Token");
          throw WrongAuthException(total_response["message"]);
        }
        print("EXCEPTION" + total_response["message"]);
        print(total_response);
        throw Exception(total_response["message"].toString());
      }
    });
  }

  Future<http.Response> _sendRequest(String path, RequestType rType,
      [Map<String, dynamic>? body, bool login = false]) async {
    print("sending request:");
    print("path:" + path);
    print("body:" + jsonEncode(body));
    body = {...?body};
    if ((_auth_token == null || (await _auth_token) == null) && !login) {
      throw NoAuthException();
    }
    if (!login) {
      body.addAll({'auth': await _auth_token!});
    }
    if (kDebugMode) {
      body.addAll({"debug": "1"});
    }

    return rType.method(
      path,
      body,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Content-Encoding": "gzip",
      },
    ).then((value) {
      print("sending request:");
      print("path:" + path);

      print("body:" + body.toString());
      print("response: ");
      print(value.body);
      print(value.body.length);
      print(value.runtimeType);
      print(value.statusCode);
      print(value);
      print("\n\n");
      return value;
    });
  }

  Future<bool> testConnection() async {
    return await _sendRequest("auth", RequestType.GET).then((value) {
      if (value.statusCode == 200) {
        return true;
      }
      return false;
    });
  }
}
