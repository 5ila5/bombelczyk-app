import 'aufzug_list_item.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'web_comunicater.dart';

class Buttons extends StatelessWidget {
  bool first;
  bool last;
  Color arrowColor = Colors.green;
  Color deleteColor = Colors.red;
  Color tablecolor;
  double buttonSize = 30;

  Buttons(
      {Key key,
      this.first = false,
      this.last = false,
      this.tablecolor = Colors.white})
      : super(key: key);

  void move(bool up) {
    //TODO Implement Move
    throw UnimplementedError();
  }

  void delete() {
    //TODO Implement Move
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: tablecolor,
        child: Row(children: [
          InkWell(
            onTap: () {
              move(true);
            },
            child: Icon(Icons.arrow_upward_outlined,
                color: arrowColor, size: buttonSize),
          ),
          InkWell(
            onTap: () {
              move(false);
            },
            child: Icon(Icons.arrow_downward_outlined,
                color: arrowColor, size: buttonSize),
          ),
          InkWell(
            child: Icon(Icons.delete, color: deleteColor, size: buttonSize),
          ),
        ]));
  }
}

class EventList {
  DateTime _lastWebCall;
  static EventList _instance;
  List<Event> events = [];

  EventList._();

  static EventList getInstance() {
    if (_instance == null) {
      return new EventList._();
    }
    return _instance;
  }

  Duration lastWebCall() {
    if (_lastWebCall == null) {
      return Duration(days: 10);
    } else {
      return _lastWebCall.difference(DateTime.now()).abs();
    }
  }

  /*EventList({this.events, String json = ""}) {
    if (this.events != null && this.events != [] && json != null && json != "")
      _initWithJson(json);
    else
      events = [];
  }*/
  EventList setEventsWithJson(String json) {
    _initWithJson(json);
    return this;
  }

  EventList setEvents(List<Event> e) {
    this.events = e;
    return this;
  }

  save() async {
    SharedPreferences prefs = await Preferences.getPrefs();
    if (prefs != null) {
      prefs.setString("events", this.toJson());
    }
  }

  void _initWithJson(String json) {
    List<dynamic> tmpList = jsonDecode(json);
    List<Event> toReturn = [];
    tmpList.forEach((element) {
      toReturn.add(Event(element["id"], DateTime.parse(element["date"]),
          element["text"], element["afz"]));
    });
    events = toReturn;
  }

  EventList clear() {
    this.events = [];
    return this;
  }

  Future<EventList> loadFromWeb() async {
    _lastWebCall = DateTime.now();
    String response = await WebComunicater.sendRequest({
      "get_events": "1",
    });
    if (response == null) {
      return null;
    }
    response = response.replaceAll("\n", "");
    List<dynamic> tmp = List<dynamic>.from(jsonDecode(response));
    EventList eventList = EventList.getInstance();
    eventList.clear();

    tmp.forEach((element) {
      DateTime eventTime = DateTime.parse(element["Datum"]);

      eventList.add(
          Event(element["id"], eventTime, element["comment"], element["afz"]));
    });
    //print(eventList.toString());
    eventList.save();
    return eventList;
  }

  Future<EventList> load() async {
    SharedPreferences prefs = await Preferences.getPrefs();
    EventList instance = getInstance();
    if (prefs != null && prefs.containsKey("events")) {
      instance.setEventsWithJson(prefs.get("events"));
    }
    return instance;
  }

  String toJson() {
    String toReturn = "[";
    events.forEach((element) {
      toReturn += element.toJson() + ", ";
    });
    toReturn = toReturn.substring(0, toReturn.length - 2) + "]\n";
    return toReturn;
  }

  void forEach(void action(Event element)) {
    for (Event element in events) action(element);
  }

  void add(Event e) {
    events.add(e);
  }

  void addAll(List<Event> e) {
    events.addAll(e);
  }

  int length() {
    return events.length;
  }
}

class Aufzug {
  int _AfzIdx;
  String _Anr;
  String _Astr;
  String _Ahnr;
  int _plz;
  String _Ort;
  String _FK_zeit;
  String _Zg_txt;

  Aufzug(Map<String, dynamic> afzMap) {
    _AfzIdx = afzMap["AfzIdx"];
    _Anr = afzMap["Anr"];
    _Astr = afzMap["Astr"];
    _Ahnr = afzMap["Ahnr"];
    _plz = afzMap["plz"];
    _Ort = afzMap["Ort"];
    _FK_zeit = afzMap["FK_zeit"];
    _Zg_txt = afzMap["Zg_txt"];
  }

  String toJson() {
    return '{"AfzIdx":' +
        _AfzIdx.toString() +
        ',"Anr":"' +
        _Anr +
        '","Astr":"' +
        _Astr +
        '","Ahnr":"' +
        _Ahnr +
        '","plz":' +
        _plz.toString() +
        ',"Ort":"' +
        _Ort +
        '","FK_zeit":"' +
        _FK_zeit +
        '","Zg_txt":"' +
        _Zg_txt +
        '"}';
  }

  @override
  String toString() {
    return this.toJson();
  }

  bool hasIdx(int idx) {
    return (idx == this._AfzIdx);
  }

  int getAfzIdx() {
    return this._AfzIdx;
  }

  String getAnr() {
    return this._Anr;
  }

  String getAstr() {
    return this._Astr;
  }

  String getAhnr() {
    return this._Ahnr;
  }

  int getplz() {
    return this._plz;
  }

  String getOrt() {
    return this._Ort;
  }

  String getFK_zeit() {
    return this._FK_zeit;
  }

  String getZg_txt() {
    return this._Zg_txt;
  }
}

class Event {
  final List<Aufzug> afz = [];
  final DateTime date;
  final String text;
  final int id;

  Event(this.id, this.date, this.text, List<dynamic> afz) {
    afz.forEach((element) {
      this.afz.add(Aufzug(element));
    });
  }

  bool containsAfz(Aufzug aufzug) {
    print(afz.toString());
    int idx = aufzug.getAfzIdx();
    afz.forEach((element) {
      if (element.hasIdx(idx)) {
        return true;
      }
    });
    return false;
  }

  bool containsAfzWithIdx(int idx) {
    print(afz.toString());
    afz.forEach((element) {
      if (element.hasIdx(idx)) {
        return true;
      }
    });
    return false;
  }

  String toJson() {
    return "{ \"afz\": " +
        jsonEncode(afz) +
        ", \"date\": \"" +
        date.toString() +
        "\", \"text\": \"" +
        text +
        "\", \"id\": " +
        id.toString() +
        "}";
  }

  List<Widget> getAfzWidgets() {
    bool even = false;
    Color tablecolor;

    print("zeug" + afz.toString());
    List<Widget> toReturn = [];
    bool first = true;
    int count = 0;
    this.afz.forEach((e) {
      count++;
      if (even) {
        tablecolor = Colors.white;
      } else {
        tablecolor = Colors.grey[300];
      }
      even = !even;
      print(e.toString());
      toReturn.add(AufzugListItem(
        zgTxt: e.getZg_txt(),
        plz: e.getplz().toString(),
        ort: e.getOrt(),
        fKZeit: e.getFK_zeit(),
        astr: e.getAstr(),
        anr: e.getAfzIdx().toString(),
        ahnr: e.getAhnr(),
        afzIdx: e.getAfzIdx().toString(),
        tablecolor: tablecolor,
      ));
      toReturn.add(Buttons(
          first: first,
          last: (this.afz.length <= count),
          tablecolor: tablecolor));
      first = false;
    });
    return toReturn;
  }

  @override
  String toString() => toJson();
}
