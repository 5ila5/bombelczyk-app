import 'package:photo_view/photo_view_gallery.dart';

import 'aufzug_list_item.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'web_comunicater.dart';
import 'tour_get_general.dart';
import 'package:photo_view/photo_view.dart';

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
  final bool first;
  final bool last;
  final Color arrowColor = Colors.green;
  final Color deleteColor = Colors.red;
  final Color /*!*/ tablecolor;
  final double buttonSize = 30;
  final EventList eventList = EventList.getInstance();
  final Event event;
  final int afzIdx;
  final int sort;

  final Function() refresh;

  Buttons(this.event, this.sort, this.afzIdx,
      {Key key,
      this.refresh,
      this.first = false,
      this.last = false,
      this.tablecolor /*!*/ = Colors.white})
      : super(key: key);

  Future<void> move(bool up) async {
    await this.event.afzMove(up, sort, afzIdx);
    if (this.refresh != null) this.refresh();
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget remindButton = TextButton(
      child: Text("Ja"),
      onPressed: () {
        this.event.afzDelete(sort, afzIdx);
        if (this.refresh != null) this.refresh();
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
  static final EventList _instance = new EventList._();
  List<Event> events = [];

  EventList._();

  static EventList getInstance() {
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
    SharedPreferences prefs = await Preferences.getPrefs();
    prefs.setString("events", this.toJson());
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
    if (response == "notLoggedIn") {
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
  int /*!*/ _afzIdx = -1;
  String /*!*/ _anr = "0";
  String _astr = "";
  String _ahnr = "";
  int _plz = 00000;
  String _ort = "";
  String _fkZeit = "";
  String _zgTxt = "";
  String _arbeit = "";
  bool _erledigt = false;
  int _anzImg = 0;
  String _beschreibung = "";

  Aufzug(Map<String, dynamic> afzMap) {
    if (afzMap["AfzIdx"] is String) {
      afzMap["AfzIdx"] = int.parse(afzMap["AfzIdx"]);
    }
    if (afzMap["plz"] is String) {
      afzMap["plz"] = int.parse(afzMap["plz"]);
    }
    _afzIdx = afzMap["AfzIdx"];
    _anr = afzMap["Anr"];
    _astr = afzMap["Astr"];
    _ahnr = afzMap["Ahnr"];
    _plz = afzMap["plz"];
    _ort = afzMap["Ort"];
    _fkZeit = afzMap["FK_zeit"];
    _zgTxt = afzMap["Zg_txt"];
    if (afzMap.containsKey("art")) {
      _arbeit = afzMap["art"];
    }
    if (afzMap.containsKey("arbeit")) {
      _arbeit = afzMap["arbeit"];
    }
    if (afzMap.containsKey("anzImg")) {
      if (afzMap["anzImg"] is String)
        _anzImg = int.parse(afzMap["anzImg"]);
      else
        _anzImg = afzMap["anzImg"];
    } else {
      _anzImg = 0;
    }
    if (afzMap.containsKey("beschreibung")) {
      _beschreibung = afzMap["beschreibung"];
    } else {
      _beschreibung = "";
    }

    if (afzMap.containsKey("erledigt")) {
      _erledigt = (afzMap["erledigt"] == 1 ||
          (afzMap["erledigt"] is String &&
              afzMap["erledigt"].toLowerCase() == 'true'));
    }
  }

  Aufzug.fromArgs(this._afzIdx, this._anr, this._astr, this._ahnr, this._plz,
      this._ort, this._fkZeit, this._zgTxt,
      [this._arbeit, this._erledigt, this._anzImg]) {
    if (this._astr == null) {
      this._astr = "";
    }
    if (this._ahnr == null) {
      this._ahnr = "";
    }
    if (this._plz == null) {
      this._plz = 00000;
    }
    if (this._ort == null) {
      this._ort = "";
    }
    if (this._fkZeit == null) {
      this._fkZeit = "";
    }
    if (this._zgTxt == null) {
      this._zgTxt = "";
    }
  }

  String toJson() {
    String toReturn = '{"AfzIdx":' +
        _afzIdx.toString() +
        ',"Anr":"' +
        _anr +
        '","Astr":"' +
        _astr +
        '","Ahnr":"' +
        _ahnr +
        '","plz":' +
        _plz.toString() +
        ',"Ort":"' +
        _ort +
        '"';
    if (_fkZeit != null) {
      toReturn += ',"FK_zeit":"' + _fkZeit + '"';
    }
    if (_zgTxt != null) {
      toReturn += ',"Zg_txt":"' + _zgTxt + '"';
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
    if (_beschreibung != null) {
      toReturn += ',"beschreibung":"' + _beschreibung + '"';
    }
    if (_anzImg != null) {
      toReturn += ',"anzImg":"' + _anzImg.toString() + '"';
    }
    toReturn += '}';
    return toReturn;
  }

  @override
  String toString() {
    return this.toJson();
  }

  bool hasIdx(int idx) {
    return (idx == this._afzIdx);
  }

  int getAfzIdx() {
    return this._afzIdx;
  }

  String getAnr() {
    return this._anr;
  }

  String /*!*/ getAstr() {
    if (this._astr == null) return "";
    return this._astr;
  }

  String /*!*/ getAhnr() {
    if (this._ahnr == null) return "";
    return this._ahnr;
  }

  int /*!*/ getplz() {
    if (this._plz == null) return 00000;
    return this._plz;
  }

  String /*!*/ getOrt() {
    if (this._ort == null) return "";
    return this._ort;
  }

  String /*!*/ getFkZeit() {
    if (this._fkZeit == null) return "";
    return this._fkZeit;
  }

  String /*!*/ getZgTxt() {
    if (this._zgTxt == null) return "";
    return this._zgTxt;
  }

  String /*!*/ getArbeit() {
    if (this._arbeit == null) return "";
    return this._arbeit;
  }

  int /*!*/ getAnzImg() {
    if (this._anzImg == null) return 0;
    return this._anzImg;
  }

  String /*!*/ getBeschreibugn() {
    if (this._beschreibung == null) return "";
    return this._beschreibung;
  }

  bool /*!*/ getErledigt() {
    if (this._erledigt == null) return false;
    return this._erledigt;
  }

  void setArbeit(String arbeit) {
    this._arbeit = arbeit;
  }

  void setErledigt(bool erledigt, {int tourIdx}) {
    this._erledigt = erledigt;
    if (tourIdx != null) {
      WebComunicater.sendRequest(<String, String>{
        "afz_erledigt": this._afzIdx.toString(),
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
  String /*!*/ text;
  int /*!*/ id;
  TourGeneralInfo tourInfos = TourGeneralInfo.getInstance();

  Event(this.id, this.date, this.text, List<dynamic> afz) {
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
    await EventList.getInstance().save();

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

  void showImage(context, int afzIdx) {
    Future<String> response = WebComunicater.sendRequest(<String, String>{
      "getImage": "1",
      "afzIdx": afzIdx.toString(),
      "tourIdx": this.id.toString()
    });
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              child: FutureBuilder(
                  future: response,
                  builder: (context, snapshot) {
                    Widget toReturn;
                    //print(snapshot.hasData);
                    // print(snapshot.data);
                    if (snapshot.hasData) {
                      //log(snapshot.data);
                      List<String> photolist =
                          (List<String>.from(jsonDecode(snapshot.data)));

                      toReturn = PhotoViewGallery.builder(
                          itemCount: photolist.length,
                          builder: (BuildContext context, int index) {
                            return PhotoViewGalleryPageOptions(
                              imageProvider:
                                  MemoryImage(base64Decode(photolist[index])),
                              initialScale: PhotoViewComputedScale.contained,
                              minScale: PhotoViewComputedScale.contained,
                              maxScale: PhotoViewComputedScale.contained * 4,
                            );
                          });
                    } else {
                      toReturn = CircularProgressIndicator();
                    }
                    return toReturn;
                  }));
        });
  }

  List<Widget> getAfzWidgets(
      {Function refresh,
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
      if (e != null) {
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
          zgTxt: e.getZgTxt(),
          plz: e.getplz().toString(),
          ort: e.getOrt(),
          fKZeit: e.getFkZeit(),
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
            if (refresh != null) refresh(),
          },
          beschreibung: e.getBeschreibugn(),
          anzImg: e.getAnzImg(),
          showImg: showImage,
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
      }
    });

    return toReturn;
  }

  List<int> getAfzArbeit() {
    List<int> toReturn = [];
    this.afz.forEach((element) {
      if (element != null)
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

  getDate() {
    return this.date;
  }
}
