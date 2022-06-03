import 'aufzug_list_item.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'web_comunicater.dart';
import 'dart:developer';
import 'tour_get_general.dart';

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
    await this.event.afzMove(up, sort, afzIdx);

    this.refresh();
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
      _initWithJson(prefs.get("events"));
    } else {}
    return this;
  }

  String toJson() {
    String toReturn = "[";
    events.forEach((element) {
      toReturn += element.toJson() + ", ";
    });
    if (toReturn.length > 2)
      toReturn = toReturn.substring(0, toReturn.length - 2);
    return toReturn + "]\n";
  }

  String toString() {
    return "instance Of EventList:" + this.toJson();
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
  String _arbeit;
  bool _erledigt;

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
    if (afzMap.containsKey("art")) {
      _arbeit = afzMap["art"];
    }
    if (afzMap.containsKey("arbeit")) {
      _arbeit = afzMap["arbeit"];
    }
    if (afzMap.containsKey("erledigt")) {
      _erledigt = (afzMap["erledigt"] == 1 ||
          (afzMap["erledigt"] is String &&
              afzMap["erledigt"].toLowerCase() == 'true'));
    }
  }

  Aufzug.fromArgs(this._AfzIdx, this._Anr, this._Astr, this._Ahnr, this._plz,
      this._Ort, this._FK_zeit, this._Zg_txt,
      {String arbeit, bool erledigt}) {
    if (this._AfzIdx == null) {
      this._AfzIdx = -1;
    }
    if (this._Anr == null) {
      this._Anr = "";
    }
    if (this._Astr == null) {
      this._Astr = "";
    }
    if (this._Ahnr == null) {
      this._Ahnr = "";
    }
    if (this._plz == null) {
      this._plz = 00000;
    }
    if (this._Ort == null) {
      this._Ort = "";
    }
    if (this._FK_zeit == null) {
      this._FK_zeit = "";
    }
    if (this._Zg_txt == null) {
      this._Zg_txt = "";
    }
    if (arbeit != null) {
      this._arbeit = arbeit;
    }
    if (erledigt != null) {
      this._erledigt = erledigt;
    }
  }

  String toJson() {
    String toReturn = '{"AfzIdx":' +
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
        '"';
    if (_FK_zeit != null) {
      toReturn += ',"FK_zeit":"' + _FK_zeit + '"';
    }
    if (_Zg_txt != null) {
      toReturn += ',"Zg_txt":"' + _Zg_txt + '"';
    }
    if (_arbeit != null) {
      //print("ARBEIT IS Not NULL");
      toReturn += ',"arbeit":"' + _arbeit + '"';
    } else {
      //print("ARBEIT IS NULL");
    }
    if (_erledigt != null) {
      toReturn += ',"erledigt":"' + _erledigt.toString() + '"';
    }
    toReturn += '}';
    return toReturn;
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

  String getArbeit() {
    return this._arbeit;
  }

  bool getErledigt() {
    return this._erledigt;
  }

  void setArbeit(String arbeit) {
    this._arbeit = arbeit;
  }

  void setErledigt(bool erledigt, {int tourIdx}) {
    this._erledigt = erledigt;
    if (tourIdx != null) {
      WebComunicater.sendRequest(<String, String>{
        "afz_erledigt": this._AfzIdx.toString(),
        "tour_for_erledigt": tourIdx.toString(),
        "erledigt": (erledigt) ? "1" : "0",
      });
      EventList eventList = EventList.getInstance();
      eventList.save();
    }
  }
}

class Event {
  final List<Aufzug> afz = [];
  DateTime date;
  String text;
  int id;
  TourGeneralInfo tourInfos = TourGeneralInfo.getInstance();

  Event(this.id, this.date, this.text, List<dynamic> afz) {
    print("CREATE EVENT");

    if (afz is List<dynamic>) {
      afz.forEach((element) {
        //print(element);
        //print(element.runtimeType);
        if ((element is Map && element["AfzIdx"] == 250) ||
            (element is String &&
                jsonDecode(element) is Map &&
                jsonDecode(element)["AfzIdx"] == 250)) {
          print(afz.toString());
          print(afz.runtimeType.toString());
        }
      });
    }

    afz.forEach((element) {
      if (element is String) {
        this.afz.add(Aufzug(jsonDecode(element)));
      } else if (element is Map<String, dynamic>) {
        this.afz.add(Aufzug(element));
      } else if (element is Aufzug) {
        this.afz.add(element);
      } else {
        print("error");
      }
    });
  }

  void addAfz(Aufzug aufzug) {
    afz.add(aufzug);
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

  Aufzug getAfzWithIdx(int idx) {
    for (var element in afz) {
      if (element.getAfzIdx() == idx) {
        print("return: " + element.toString());
        return element;
      }
    }
    return null;
  }

  String toJson() {
    //print(afz.toString());
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

  List<Widget> getAfzWidgets(
      {Function() refresh,
      Aufzug toAdd,
      bool editMode = false,
      Function customWorkWidget}) {
    bool even = false;
    Color tablecolor;

    //print("zeug" + afz.toString());
    List<Widget> toReturn = [];
    bool first = true;
    int count = 0;
    this.afz.forEach((Aufzug e) {
      count++;
      if (even) {
        tablecolor = Colors.white;
      } else {
        tablecolor = Colors.grey[300];
      }
      if (toAdd != null && e.hasIdx(toAdd.getAfzIdx())) {
        tablecolor = Colors.lightGreen;
      }
      if (e.getErledigt() != null && e.getErledigt()) {
        tablecolor = Color.fromARGB(255, 0, 255, 8);
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
        arbeit: e.getArbeit().toString(),
        tablecolor: tablecolor,
        customWorkWidget: customWorkWidget,
        erledigt: e.getErledigt(),
        check: (bool newState) => {
          print("setErledigt for Afz" + e.getAfzIdx().toString()),
          print("currSlectState:" + e.getErledigt().toString()),
          print("e.setErledigt(" +
              newState.toString() +
              ", tourIdx:" +
              this.id.toString() +
              ")"),
          e.setErledigt(newState, tourIdx: this.id),
          print(e.getErledigt()),
          refresh(),
        },
      ));
      if (this.date.isAfter(DateTime.now()) ||
          isSameDay(DateTime.now(), this.date)) {
        if (editMode) {
          toReturn.add(Buttons(this, count - 1, e.getAfzIdx(),
              refresh: refresh,
              first: first,
              last: (this.afz.length <= count),
              tablecolor: tablecolor));
        }
        first = false;
      }
    });

    return toReturn;
  }

  List<int> getAfzArbeit() {
    List<int> toReturn = [];
    this.afz.forEach((element) {
      toReturn.add(tourInfos.getArbeitsIdx(element.getArbeit()));
    });
    return toReturn;
  }

  @override
  String toString() => toJson();

  List<int> getAfzIdxList() {
    List<int> toReturn = [];
    afz.forEach((element) {
      toReturn.add(element.getAfzIdx());
    });
    return toReturn;
  }
}
