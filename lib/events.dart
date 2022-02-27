import 'aufzug_list_item.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'web_comunicater.dart';
import 'dart:developer';

import 'package:intl/intl.dart';

/* class EventListDebug {
  static show(String prefix) {
    List<Event> evenets = EventList.getInstance().events;
    /*log(prefix +
        "\n EventsLength:" +
        evenets.length.toString() +
        "\nEvents:" +
        evenets.toString());
  */
  }
} */

class Buttons extends StatelessWidget {
  bool first;
  bool last;
  Color arrowColor = Colors.green;
  Color deleteColor = Colors.red;
  Color tablecolor;
  double buttonSize = 30;
  EventList eventList = EventList.getInstance();
  Event event;
  int afzIdx;
  int sort;

  Function() refresh;

  Buttons(this.event, this.sort, this.afzIdx,
      {Key key,
      this.refresh,
      this.first = false,
      this.last = false,
      this.tablecolor = Colors.white})
      : super(key: key);

  Future<void> move(bool up) async {
/*     print("move");
    EventListDebug.show("Move Start"); */
    await this.event.afzMove(up, sort, afzIdx);
    // EventListDebug.show("Move after afzMove");
    this.refresh();
    // EventListDebug.show("Move after refresh");
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget remindButton = TextButton(
      child: Text("Ja"),
      onPressed: () {
        this.event.afzDelete(sort, afzIdx);
        refresh();
        Navigator.pop(context);
      },
    );
    Widget cancelButton = TextButton(
      child: Text("Abbrechen"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Notice"),
      content: Text(
          "Bist du sicher, dass du den Aufzug aus dieser Liste entfernen möchtest?"),
      actions: [
        remindButton,
        cancelButton,
      ],
    ); // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void delete(BuildContext context) {
    // print("delete");
    showAlertDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 15),
        alignment: Alignment.topLeft,
        color: tablecolor,
        child: Container(
            width: buttonSize * 3,
            child: Row(children: [
              Expanded(
                flex: 1,
                child: (!first)
                    ? InkWell(
                        onTap: () {
                          move(true);
                        },
                        child: Icon(Icons.arrow_upward_outlined,
                            color: arrowColor, size: buttonSize),
                      )
                    : Text(""),
              ),
              Expanded(
                flex: 1,
                child: (!last)
                    ? InkWell(
                        onTap: () {
                          move(false);
                        },
                        child: Icon(Icons.arrow_downward_outlined,
                            color: arrowColor, size: buttonSize),
                      )
                    : Text(""),
              ),
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    delete(context);
                  },
                  child:
                      Icon(Icons.delete, color: deleteColor, size: buttonSize),
                ),
              ),
            ])));
  }
}

class EventList {
  DateTime _lastWebCall;
  static EventList _instance;
  List<Event> events = [];

  EventList._();

  static EventList getInstance() {
    if (_instance == null) {
      // print("create new Instance of EventList");
      _instance = new EventList._();
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

  EventList setEvents(List<Event> e) {
    this.events = e;
    return this;
  }

  save() async {
    // print("start save");
    SharedPreferences prefs = await Preferences.getPrefs();
    if (prefs != null) {
      prefs.setString("events", this.toJson());
      // print(this.toJson());
    } else {
      // print("erro no Prefs");
    }
    // print("end Save");
  }

  void _initWithJson(String json) {
    // print("in _initWithJson");
    List<dynamic> tmpList = jsonDecode(json);
    events = [];
    tmpList.forEach((element) {
      // print("in For Each");
      events.add(Event(element["id"], DateTime.parse(element["date"]),
          element["text"], element["afz"]));
    });
  }

  EventList clear() {
    // log("Clear events");
    this.events = [];
    return this;
  }

  Future<EventList> loadFromWeb() async {
    _lastWebCall = DateTime.now();
    String response = await WebComunicater.sendRequest({
      "get_events": "1",
    });
    if (response == null) {
      return this;
    }

    // log("response is There:" + response);
    response = response.replaceAll("\n", "");
    List<dynamic> tmp = List<dynamic>.from(jsonDecode(response));
    // EventListDebug.show("Load From Web before clear");

    clear();
    // EventListDebug.show("Load From Web after clear");
    // log("tmp:" + tmp.toString());

    tmp.forEach((element) {
      // log("tmp.forEach element:" + element.toString());
      DateTime eventTime = DateTime.parse(element["Datum"]);

      events.add(
          Event(element["id"], eventTime, element["comment"], element["afz"]));
      // log(events.toString());
      // EventListDebug.show("in forEach");
    });
    // EventListDebug.show("Load From Web before Save");
    //print(eventList.toString());
    save();
    // EventListDebug.show("Load From Web after Save");

    return this;
  }

  Future<EventList> load() async {
    SharedPreferences prefs = await Preferences.getPrefs();
    if (prefs != null && prefs.containsKey("events")) {
/*       print(
          "_initWithJson(" + jsonDecode(prefs.get("events")).toString() + ")"); */
      _initWithJson(prefs.get("events"));
    } else {
      // print("PrefsError in eveents.dart L 210");
    }
    return this;
  }

  String toJson() {
/*     print("start To JSON");
    print(events.length);
    print(events.toString()); */
    String toReturn = "[";
    events.forEach((element) {
      toReturn += element.toJson() + ", ";
    });
    if (toReturn.length > 2)
      toReturn = toReturn.substring(0, toReturn.length - 2);
    return toReturn + "]\n";
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
    if (afzMap["AfzIdx"] is String) {
      afzMap["AfzIdx"] = int.parse(afzMap["AfzIdx"]);
    }
    if (afzMap["plz"] is String) {
      afzMap["plz"] = int.parse(afzMap["plz"]);
    }
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
      if (element is String) {
        this.afz.add(Aufzug(jsonDecode(element)));
      } else if (element is Map<String, dynamic>) {
        this.afz.add(Aufzug(element));
      } else {
        print("error");
      }
    });
  }

  bool isSameDay(DateTime a, DateTime b) {
    if (a == null || b == null) {
      return false;
    }

    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool afzDelete(int indx, int afzIdx) {
    if (indx >= afz.length) {
      return false;
    }

    afz.removeAt(indx);
    EventList.getInstance().save();
    WebComunicater.sendRequest(<String, String>{
      "tourAfzDelete": "true",
      "afzIdx": afzIdx.toString(),
      "id": this.id.toString(),
    }).then((r) => print("Delete Response: " + r));
    return true;
  }

  Future<bool> afzMove(bool up, int indx, int afzIdx) async {
    if ((up && indx == 0) ||
        (!up && indx == afz.length - 1) ||
        indx >= afz.length) {
      return false;
    }
    Aufzug tmp = afz[indx];
    afz[indx] = afz[indx + ((up) ? -1 : 1)];
    afz[indx + ((up) ? -1 : 1)] = tmp;
    WebComunicater.sendRequest(<String, String>{
      "tourAfzMove": "true",
      "afzIdx": afzIdx.toString(),
      "up": up.toString(),
      "id": this.id.toString(),
    }).then((r) => print(r));
    // print("event Length" + EventList.getInstance().events.length.toString());
    // EventListDebug.show("afzMove before Save");
    await EventList.getInstance().save();
    // EventListDebug.show("afzMove after Save");

    return true;
  }

  bool containsAfz(Aufzug aufzug) {
    int idx = aufzug.getAfzIdx();
    bool toReturn = false;
    afz.forEach((element) {
      if (element.hasIdx(idx)) {
        toReturn = true;
      }
    });
    return toReturn;
  }

  bool containsAfzWithIdx(int idx) {
    // print(afz.toString());
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

  List<Widget> getAfzWidgets({Function() refresh, Aufzug toAdd}) {
    bool even = false;
    Color tablecolor;

    //print("zeug" + afz.toString());
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
      if (toAdd != null && e.hasIdx(toAdd.getAfzIdx())) {
        tablecolor = Colors.lightGreen;
      }
      even = !even;
      //print(e.toString());
      toReturn.add(AufzugListItem(
        zgTxt: e.getZg_txt(),
        plz: e.getplz().toString(),
        ort: e.getOrt(),
        fKZeit: e.getFK_zeit(),
        astr: e.getAstr(),
        anr: e.getAnr().toString(),
        ahnr: e.getAhnr(),
        afzIdx: e.getAfzIdx().toString(),
        tablecolor: tablecolor,
      ));
      if (this.date.isAfter(DateTime.now()) ||
          isSameDay(DateTime.now(), this.date)) {
        toReturn.add(Buttons(this, count - 1, e.getAfzIdx(),
            refresh: refresh,
            first: first,
            last: (this.afz.length <= count),
            tablecolor: tablecolor));
        first = false;
      }
    });

    return toReturn;
  }

  @override
  String toString() => toJson();
}
