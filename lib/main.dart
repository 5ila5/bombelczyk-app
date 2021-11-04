import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;


import 'package:url_launcher/url_launcher.dart';
//import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';


//import 'dart:developer' as developer;

import 'package:geolocator/geolocator.dart';

enum Sorts {
  Aufzugsnummer,
  Strasse,
  Postleitzahl,
  Ort,
  Anfahrtszeit,
}
enum ToDoSorts {
  Aufzugsnummer,
  Strasse,
  Postleitzahl,
  Ort,
  Anfahrtszeit,
  Erledigt_Datum,
  Erstelldatum,
  ToDoText,
}

/*class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}*/

void main() {
  runApp(MyApp());
}

class AuthKey {
  static final _passwordController = TextEditingController();

  static void wrongKey(BuildContext context) {
    displayTextInputDialog(context);
  }

  static void setKey(BuildContext context) async {
    //print("setKey");
    SharedPreferences prefs;
    if (Preferences.prefs == null) {
      prefs = await Preferences.initPrefs();
    } else {
      prefs = Preferences.prefs;
    }
    String pass = _passwordController.text;
    //print("pass:"+pass);
    if (pass.length < 1) {
      AuthKey.wrongKey(context);

      return;
    }
    String response = await WebComunicater
        .sendRequest(<String, String>{'password': pass}, login: true);
    String respnse = response.replaceAll("\n", "");
    if (respnse == "false" || respnse.length != 32) {
      //print("false:");
      AuthKey.wrongKey(context);

      return;
    }

    prefs.setString("key", respnse);
  }

  static Future<void> displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Passwort:'),
            content: TextField(
              onSubmitted: (value) {
                setKey(context);
                Navigator.pop(context);
              },
              controller: _passwordController,
              decoration: InputDecoration(hintText: "Passwort"),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  elevation: 10.0,
                  shadowColor: Colors.blueGrey,
                  primary: Colors.white,
                  backgroundColor: Colors.blue,
                  onSurface: Colors.grey,
                ),
                child: Text('OK'),
                onPressed: () {
                  //setState(() {
                  //codeDialog = valueText;
                  setKey(context);
                  Navigator.pop(context);
                  //});
                },
              ),
            ],
          );
        });
  }
}

class WebComunicater {
  static final String _ipToAsk = 'bombelczyk-aufzuege.de';
  static final gzip = GZipCodec();

  static Future<String> sendRequest(Map<String, String> body,
      {bool login = false}) async {
    http.Response response = await http.post(
      Uri.https(_ipToAsk,
          'UpP0UH3nFKMsnJk2/' + ((login) ? 'login.php' : 'index.php')),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Content-Encoding": "gzip",
      },
      body: gzip.encode(jsonEncode(body).codeUnits),
    );
    return response.body;
  }
}

class Preferences {
  static SharedPreferences prefs;

  static Future<SharedPreferences> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    return prefs;
  }
}

class AufzugsArgumente {
  final Future<String> json;
  final String afzIdx;
  final String aNr;
  final String aStr;
  final String aPLZ;
  final String aOrt;
  final String aFZ;
  final String schluessel;

  AufzugsArgumente(this.afzIdx, this.aNr, this.json, this.aStr, this.aPLZ,
      this.aOrt, this.aFZ, this.schluessel);

  void printArgs() async {
    print("printArgs");
    print(await this.json);
    print("VERY IMPORTANT");
    //print(this.json.);
  }
}

class SelectElevator {
  static void selectElevator(String afzIdx, String nr, String str, String pLZ,
      String ort, String fZ, String schluessel, BuildContext context) async {
    SharedPreferences prefs;
    if (Preferences.prefs == null) {
      prefs = await Preferences.initPrefs();
    } else {
      prefs = Preferences.prefs;
    }

    Future<String> response = WebComunicater.sendRequest(<String, String>{
      'AfzIdx': afzIdx,
      'auth': prefs.getString("key"),
    });


    //Future<String> responseStr = response.replaceAll("\n", "");
    AufzugsArgumente args = AufzugsArgumente(afzIdx, nr, response, str, pLZ, ort, fZ, schluessel);
    args.printArgs();
    Navigator.pushNamed(
      context,
      Aufzug.aufzugRoute,
      arguments: args,
    );
  }
}

class Aufzug extends StatelessWidget {
  static const aufzugRoute = '/aufzugRoute';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AufzugPage(title: 'Aufzugs Übersicht');
  }
}

//ignore: must_be_immutable
class AufzugToDo extends StatefulWidget {
  Map<String, dynamic> toDoMap;
  String afzIdx;

  AufzugToDo({this.afzIdx, this.toDoMap, Key key}) : super(key: key);

  @override
  AufzugToDoState createState() => AufzugToDoState();
}

class AufzugToDoState extends State<AufzugToDo> {
  //Map <String,dynamic> toDoMap=Widget.;
  Map<String, dynamic> addedTodos = {};
  Map<String, String> checkboxStates = {};
  Map<String, String> savedText = {};

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  void createNewToDo(String key, String aidx) async {
    String response = await WebComunicater.sendRequest(<String, String>{
      'auth': Preferences.prefs.getString("key"),
      'toDoNewText': addedTodos[key]['text'],
      'AfzIdx': aidx,
      'toDoSet': (addedTodos[key]["checked"] != "").toString(),
    });
    print("create new ToDo" + key);
    print("response: " + response);
    if (isNumeric(response)) {
      addedTodos[key]["idx"] = int.parse(response).toString();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Map<String, TextEditingController> textController = {};

    List<Widget> widgetList = [
      InkWell(
        child: Icon(Icons.add, size: 40, color: Colors.blue),
        onTap: () {
          int newKey = 1000;
          while (widget.toDoMap.containsKey(newKey.toString())) {
            newKey++;
          }
          DateTime now = DateTime.now();
          DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
          String formatted = formatter.format(now);
          addedTodos[newKey.toString()] = <String, String>{
            "created": formatted,
            "checked": "",
            "text": "",
            //"new": "new",
          };
          print("added " +
              newKey.toString() +
              " addedTodo:" +
              addedTodos.toString());

          setState(() {});
        },
      ),
      Divider(thickness: 1, color: Colors.grey),
    ];
    //addedTodos.addAll(toDoMap);
    Map<String, dynamic> newMap = {};
    newMap.addAll(addedTodos);
    newMap.addAll(widget.toDoMap);
    widget.toDoMap = newMap;
    //toDoMap=addedTodos;
    print("addedTodos" + addedTodos.toString());
    print("newMap" + newMap.toString());
    print("toDoMap" + widget.toDoMap.toString());

    widget.toDoMap.forEach((key, value) {
      if (value["created"] == null) {
        value["created"] = "";
      }
      if (value["checked"] == null) {
        value["checked"] = "";
      }
      if (value["text"] == null) {
        value["text"] = "";
      }

      print("|" + value["text"] + "|");
      print("|" + value["checked"] + "|");
      print("|" + "toDoMap[" + key.toString() + "][\"checked\"]" + "|");
      print("|" + widget.toDoMap[key]["checked"] + "|");

      //workWidget.add(Text("hier Kommen To-Dos hin"));

      bool checkBoxVal;
      if (checkboxStates.containsKey(key)) {
        checkBoxVal = (checkboxStates[key] != "");
      } else {
        checkBoxVal = value["checked"] != "" &&
            value["checked"] != "0000-00-00 00:00:00" &&
            value["checked"] != "NULL";
      }

      if (savedText.containsKey(key)) {
        print("savedController contains Key");
        textController[key] = TextEditingController(text: savedText[key]);
        print(savedText[key]);
        print(textController[key].text);
      } else {
        textController[key] = TextEditingController(text: value["text"]);
      }

      widgetList.add(
        Table(columnWidths: {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(6),
        }, children: [
          TableRow(children: [
            Checkbox(
              value: (checkBoxVal),
              onChanged: (bool newValue) {
                DateTime now = DateTime.now();
                DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
                String formatted = formatter.format(now);

                //printFutureResponse(
                if (!value.containsKey("idx")) {
                  addedTodos[key]["checked"] = (newValue) ? formatted : "";
                  if (newValue) {
                    addedTodos[key]["text"] = textController[key].text;
                    createNewToDo(key.toString(), widget.afzIdx);
                  }
                } else {
                  WebComunicater.sendRequest(<String, String>{
                    'auth': Preferences.prefs.getString("key"),
                    'toDoSet': newValue.toString(),
                    'toDoIdx': value['idx'].toString(),
                  });
                }
                setState(() {
                  if (checkBoxVal) {
                    print("set " + key.toString() + " to False");
                    checkboxStates[key] = "";
                  } else {
                    print("set " + key.toString() + " to " + formatted);
                    checkboxStates[key] = formatted;
                  }
                });
              },
            ),
            Column(
              children: [
                (checkBoxVal)
                    ? SelectableText(textController[key].text)
                    : Column(children: [
                        TextField(
                          controller: textController[key],
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: const InputDecoration(
                              //border: OutlineInputBorder(),
                              //hintText: 'Enter a search term'
                              ),
                        ),
                        Row(children: [
                          InkWell(
                              child: Icon(Icons.save_outlined,
                                  size: 40, color: Colors.green),
                              onTap: () {
                                if (!value.containsKey("idx")) {
                                  addedTodos[key]["text"] =
                                      textController[key].text;
                                  createNewToDo(key.toString(), widget.afzIdx);
                                } else {
                                  WebComunicater.sendRequest(<String, String>{
                                    'auth': Preferences.prefs.getString("key"),
                                    'toDoNewText': textController[key].text,
                                    'toDoIdx': value['idx'].toString(),
                                  });
                                }
                                setState(() {
                                  savedText[key] = textController[key].text;
                                });
                              }),
                          InkWell(
                            child:
                                Icon(Icons.cancel, size: 40, color: Colors.red),
                            onTap: () {
                              setState(() {});
                            },
                          ),
                        ]),
                      ]),
              ],
            ),
          ]),
        ]),
      );
      widgetList.add(Divider(thickness: 1, color: Colors.grey));
    });
    return Column(children: widgetList);
  }
}

class ToDoHome extends StatefulWidget {
  //Map <String,dynamic> toDoresponseMap;
  //String afzIdx;

  ToDoHome({Key key}) : super(key: key);

  @override
  ToDoHomeState createState() => ToDoHomeState();
}

class ToDoHomeState extends State<ToDoHome> {
  bool _toDoSortDirection = false;
  int _toDoSort = 1;
  TextEditingController _searchToDoController = new TextEditingController();
  bool _toDoShowChecked = false;
  bool _toDoShowUnchecked = true;
  Future<Map<String, dynamic>> toDoresponseMap;
  bool firstBuild = true;

  refreshToDoTable(String text) async {
    setState(() {
      toDoresponseMap = searchToDos(text);
    });
  }

  Future<Map<String, dynamic>> searchToDos(String search) async {
    Map<String, dynamic> tmpResponseMap = {};
    SharedPreferences prefs;
    if (Preferences.prefs == null) {
      prefs = await Preferences.initPrefs();
    } else {
      prefs = Preferences.prefs;
    }
    if (!prefs.containsKey("key")) {
      AuthKey.wrongKey(context);
      return {};
    }

    String response = await WebComunicater.sendRequest(<String, String>{
      'toDoSearchText': search,
      'auth': prefs.getString("key"),
      "toDoSort": _toDoSort.toString(),
      "sortDirection": _toDoSortDirection.toString(),
      "showChecked": _toDoShowChecked.toString(),
      "showUnchecked": _toDoShowUnchecked.toString(),
    });
    print("showChecked: " +
        _toDoShowChecked.toString() +
        "\nshowUnchecked: " +
        _toDoShowUnchecked.toString());

    String responseStr = response.replaceAll("\n", "");
    print("responseStr:");
    print(response);
    if (responseStr == "false") {
      AuthKey.wrongKey(context);

      return {};
    }
    tmpResponseMap = Map<String, dynamic>.from(jsonDecode(responseStr));
    if (tmpResponseMap["error"]) {
      //_requestError = true;
      setState(() {
        print("setState");
      });
      return {};
    }
    //_requestError = false;
    tmpResponseMap.remove("error");
    //processToDos();
    return tmpResponseMap;
  }

  @override
  Widget build(BuildContext context) {
    if (firstBuild) {
      refreshToDoTable("");
      firstBuild = false;
    }
    return Column(
      children: <Widget>[
        Container(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 3, 20, 0),
            //width:200.0,

            child: TextField(
              controller: _searchToDoController,
              onChanged: (value) {
                refreshToDoTable(value);
              },
              style: TextStyle(
                //height: 1,
                //fontSize: 40.0,
                color: Colors.black,
                //backgroundColor: Colors.lightGreen,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                hintText: 'Suche To-Dos',
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ),

    //Flexible(child:
        Row(children: <Widget>[
          Container(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              //width:200.0,

              child: DropdownButton<ToDoSorts>(
                value: ToDoSorts.values[_toDoSort],
                items: ToDoSorts.values
                    .map<DropdownMenuItem<ToDoSorts>>((ToDoSorts value) {
                  return DropdownMenuItem<ToDoSorts>(
                    value: value,
                    child: Text(value.toString().replaceAll("ToDoSorts.", "")),
                  );
                }).toList(),
                onChanged: (ToDoSorts newValue) {
                  _toDoSort = newValue.index;
                  refreshToDoTable(_searchToDoController.text);
                },
                //<sorts>[10, 20, 50]
              ),
            ),
          ),
          InkWell(
            child: (_toDoSortDirection)
                ? Icon(Icons.arrow_downward)
                : Icon(Icons.arrow_upward),
            onTap: () {
              _toDoSortDirection = !_toDoSortDirection;
              refreshToDoTable(_searchToDoController.text);
            },
          ),




          (MediaQuery.of(context).orientation ==Orientation.portrait)?Column(children: [
            Row(
              children: [
                Icon(Icons.check),
                Checkbox(
                  value: _toDoShowChecked,
                  onChanged: (bool val) {
                    if (val || _toDoShowUnchecked) {
                      _toDoShowChecked = !_toDoShowChecked;
                      refreshToDoTable(_searchToDoController.text);
                    }
                  },
                )
              ],
            ),

            Row(
              children: [
                Icon(Icons.crop_square_sharp),
                Checkbox(
                  value: _toDoShowUnchecked,
                  onChanged: (bool val) {
                    if (val || _toDoShowChecked) {
                      _toDoShowUnchecked = !_toDoShowUnchecked;
                      refreshToDoTable(_searchToDoController.text);
                    }
                  },
                )
              ],
            ),
          ]):Row(children: [

                Icon(Icons.check),
                Checkbox(
                  value: _toDoShowChecked,
                  onChanged: (bool val) {
                    if (val || _toDoShowUnchecked) {
                      _toDoShowChecked = !_toDoShowChecked;
                      refreshToDoTable(_searchToDoController.text);
                    }
                  },
                ),
              Padding(padding: const EdgeInsets.fromLTRB(10, 0, 10, 0)),
                Icon(Icons.crop_square_sharp),
                Checkbox(
                  value: _toDoShowUnchecked,
                  onChanged: (bool val) {
                    if (val || _toDoShowChecked) {
                      _toDoShowUnchecked = !_toDoShowUnchecked;
                      refreshToDoTable(_searchToDoController.text);
                    }
                  },
                ),
              ],
            ),
        ]),//),
        new Expanded(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
          //padding:const EdgeInsets.fromLTRB(5, 0, 0, 3),
          child: SingleChildScrollView(
            //  child: Column(
            //children:
            child: FutureBuilder<Map<String, dynamic>>(
              future: toDoresponseMap,
              builder: (BuildContext context,
                  AsyncSnapshot<Map<String, dynamic>> snapshot) {
                if (snapshot.hasData) {
                  return ToDoHomeList(
                    toDoresponseMap: snapshot.data,
                  );
                } else if (snapshot.hasError) {
                  return Column(children: <Widget>[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text('Error: ${snapshot.error}'),
                    )
                  ]);
                } else {
                  return Column(children: const <Widget>[
                    SizedBox(
                      child: CircularProgressIndicator(),
                      width: 60,
                      height: 60,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Läd einträge...'),
                    )
                  ]);
                }
              },
//          }
            ),

            //_ToDotabelle,
            //)
          ),
        )),
      ],
    );
  }
}

//ignore: must_be_immutable
class ToDoHomeList extends StatefulWidget {
  Map<String, dynamic> toDoresponseMap;
  String afzIdx;

  ToDoHomeList({this.toDoresponseMap, Key key}) : super(key: key);

  @override
  ToDoHomeListState createState() => ToDoHomeListState();
}

class ToDoHomeListState extends State<ToDoHomeList> {
  Map<String, bool> expandedToDos = {};

  @override
  Widget build(BuildContext context) {
    if (widget.toDoresponseMap == null ||
        (widget.toDoresponseMap.containsKey("error") &&
            widget.toDoresponseMap.containsKey("error") == true))
      return Text("Für angegebene Parameter nichts Gefunden");
    bool even = true;
    Color tablecolor = Colors.grey[300];

    List<Widget> tmpTabelle = [];
    TextStyle tableRowTopStyle =
        TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey[900]);
    TextStyle tableRowBottomStyle = TextStyle(
      fontWeight: FontWeight.normal,
    );
    //toDoresponseMap.
    widget.toDoresponseMap.forEach((key, value) {
      value["todos"].remove("error");
      List<Widget> columnChildren = [
        Row(children: [
          Text(
            value["Anr"].toString() + " ",
            style: tableRowTopStyle,
          ),
          Text(value["Astr"].toString() + " " + value["Ahnr"].toString(),
              style: tableRowTopStyle),
        ]),
        Row(
          children: [
            Text(value["plz"].toString() + " ", style: tableRowBottomStyle),
            Text(value["Ort"].toString(), style: tableRowBottomStyle),
          ],
        ),
        Row(
          children: [
            Text("Anfahrt ", style: tableRowBottomStyle),
            Text(value["FK_zeit"].toString(), style: tableRowBottomStyle),
          ],
        ),
        //Divider(),
      ];
      if (value["Zg_txt"].length > 2) {
        columnChildren.add(Row(
          children: [
            Text("Schlüssel ", style: tableRowBottomStyle),
            Text(value["Zg_txt"].toString(), style: tableRowBottomStyle),
          ],
        ));
      }
      //print(value.toString());
      tmpTabelle.add(
        Container(
          padding: const EdgeInsets.only(
              right: 20.0, left: 10.0, bottom: 5.0, top: 5.0),
          //padding: const EdgeInsets.only(left: 10.0),
          color: tablecolor,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: new InkWell(
                      child: Column(
                        children: columnChildren,
                      ),
                      onTap: () {
                        print("onTap");

                        if (expandedToDos
                                .containsKey(value["afzIdx"].toString()) &&
                            expandedToDos[value["afzIdx"].toString()]) {
                          expandedToDos[value["afzIdx"].toString()] = false;
                          print("unshow");
                        } else {
                          expandedToDos[value["afzIdx"].toString()] = true;
                          print("show");
                        }
                        setState(() {});
                      },
                    ),
                  ),
                  new InkWell(
                    child: Icon(
                      Icons.elevator_outlined,
                      size: 60,
                      color: Colors.blue,
                    ),
                    onTap: () {
                      SelectElevator.selectElevator(
                          value["afzIdx"].toString(),
                          value["Anr"].toString(),
                          value["Astr"].toString() +
                              " " +
                              value["Ahnr"].toString(),
                          value["plz"].toString(),
                          value["Ort"].toString(),
                          value["FK_zeit"].toString(),
                          value["Zg_txt"].toString(),
                          context);
                    },
                  ),
                ],
              ),
              (expandedToDos.containsKey(value["afzIdx"].toString()) &&
                      expandedToDos[value["afzIdx"].toString()])
                  ? AufzugToDo(
                      afzIdx: value["afzIdx"].toString().toString(),
                      toDoMap: value["todos"])
                  : Text(""),
              //Divider(thickness: 0.0),
            ],
          ),
        ), //Container
      );
      print("expandedToDos: " + expandedToDos.toString());

      if (even) {
        tablecolor = Colors.white;
      } else {
        tablecolor = Colors.grey[300];
      }
      even = !even;
    });

    return Column(
      children: tmpTabelle,
    );
  }
}

class ToDoAufzugList extends StatefulWidget {
  ToDoAufzugList(this.response, this.afzIdx, {Key key}) : super(key: key);
  final Future<String> response;
  final String afzIdx;

  @override
  ToDoAufzugListState createState() => ToDoAufzugListState();
}

class ToDoAufzugListState extends State<ToDoAufzugList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: widget.response,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        List<Widget> children = [];
        if (snapshot.hasData) {
          Map<String, dynamic> responseMap =
              Map<String, dynamic>.from(jsonDecode(snapshot.data));
          Map<String, dynamic> toDoMap;
          if (!(responseMap["2"].runtimeType == String ||
              responseMap["2"]["error"] == "true")) {
            print('responseMap["2"]');
            print(responseMap["2"]);
            toDoMap = responseMap["2"];

            toDoMap.remove("error");
          } else {
            toDoMap = {};
          }
          return AufzugToDo(afzIdx: widget.afzIdx, toDoMap: toDoMap);
        } else if (snapshot.hasError) {
          children.addAll(
            [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              )
            ],
          );
        } else {
          children.addAll(
            [
              SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Läd einträge...'),
              )
            ],
          );
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          //crossAxisCount: 6,
          children: children,
        );
      },
//          }
    );
  }
}

class WorkList extends StatefulWidget {
  WorkList(this.response, {Key key}) : super(key: key);
  final Future<String> response;

  @override
  WorkListState createState() => WorkListState();
}

class WorkListState extends State<WorkList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: widget.response,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        List<Widget> children = [];
        if (snapshot.hasData) {
          //children = snapshot.data;
          Map<String, dynamic> responseMap =
              Map<String, dynamic>.from(jsonDecode(snapshot.data));

          if (!(responseMap["1"].runtimeType == String ||
              responseMap["1"]["error"] == "true")) {
            Map<String, dynamic> arbeitMap = responseMap["1"];
            arbeitMap.remove("error");
            print("arbeitMap".toString());
            print(arbeitMap.toString());
            arbeitMap.forEach((key, value) {
              if (value["ArbDat"] == null) {
                value["ArbDat"] = "";
              }
              if (value["MitarbeiterName"] == null) {
                value["MitarbeiterName"] = "";
              }
              if (value["AusgfArbeit"] == null) {
                value["AusgfArbeit"] = "";
              }
              if (value["Kurztext"] == null) {
                value["Kurztext"] = "";
              }

              List<String> mitarbeiterList =
                  value["MitarbeiterName"].split(",");
              //print(mitarbeiterList.toString());
              String mitarbeiter = "";
              //print(mitarbeiter);
              for (int i = 0; i < mitarbeiterList.length; i++) {
                if (i == 0)
                  mitarbeiter += mitarbeiterList[i];
                else if (!mitarbeiter
                    .replaceAll(" ", "")
                    .contains(mitarbeiterList[i].replaceAll(" ", "")))
                  mitarbeiter += "," + mitarbeiterList[i];
              }

              children.add(
                Table(
                  children: [
                    TableRow(children: [
                      SelectableText("Datum"),
                      SelectableText(value["ArbDat"]),
                    ]),
                    TableRow(children: [
                      SelectableText("Monteur(e)"),
                      SelectableText(mitarbeiter),
                      //Text(value["MitarbeiterName"]),
                    ]),
                    TableRow(children: [
                      SelectableText("Arbeit"),
                      SelectableText(value["AusgfArbeit"]),
                    ]),
                    TableRow(children: [
                      SelectableText("Kurztext"),
                      SelectableText(value["Kurztext"]),
                    ]),
                  ],
                ),
              );
              children.add(Divider(thickness: 3, color: Colors.grey));
            });
          } else {
            return Container();
          }
        } else if (snapshot.hasError) {
          children.addAll(
            [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              )
            ],
          );
        } else {
          children.addAll(
            const <Widget>[
              SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Läd einträge...'),
              )
            ],
          );
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          //crossAxisCount: 6,
          children: children,
        );
      },
//          }
    );
  }
}

class AkkuList extends StatefulWidget {
  AkkuList(this.response, {Key key}) : super(key: key);
  final Future<String> response;

  @override
  AkkuListState createState() => AkkuListState();
}

class AkkuListState extends State<AkkuList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: widget.response,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        List<TableRow> children;
        if (snapshot.hasData) {
          print("snapshot.data");
          print(snapshot.data);
          //children = snapshot.data;
          Map<String, dynamic> responseMap =
              Map<String, dynamic>.from(jsonDecode(snapshot.data));
          if (!(responseMap["0"].runtimeType == String ||
              responseMap["0"]["error"] == "true")) {
            Map<String, dynamic> akkuMap = responseMap["0"];
            akkuMap.remove("error");
            akkuMap.forEach((key, value) {
              Color rowColor = Colors.green;
              try {
                //print("try");
                DateTime date = DateTime.parse(value["TauschTag"]);
                DateTime now = DateTime.now();
                value["TauschTag"] = date.day.toString() +
                    "." +
                    date.month.toString() +
                    "." +
                    date.year.toString();
                int jZykl =
                    int.parse(value["Zykl"].replaceAll(RegExp("[^\\d.]"), ""));
                DateTime toDoTillYellow =
                    new DateTime(date.year + jZykl, date.month - 3, date.day);
                //print("date: "+date.toString());
                //print("date Till Yellow"+toDoTillYellow.toString());
                DateTime toDoTillRed =
                    new DateTime(date.year + jZykl, date.month, date.day);
                //print("date Till red "+toDoTillRed.toString());
                if (toDoTillYellow.isBefore(now)) {
                  rowColor = Colors.yellow;
                  if (toDoTillRed.isBefore(now)) {
                    rowColor = Colors.red;
                  }
                }

                //print();
              } on Exception {
                //print("somithing went wrong");
              }
              children.addAll(
                [
                  TableRow(children: [
                    Container(color: rowColor, child: Text("Menge")),
                    Container(
                        color: rowColor,
                        child: Text(value["Menge"].toString())),
                  ]),
                  TableRow(children: [
                    Container(color: rowColor, child: Text("Letzter Wchsel")),
                    Container(
                        color: rowColor,
                        child: Text(value["TauschTag"].toString())),
                  ]),
                  TableRow(children: [
                    Container(color: rowColor, child: Text("Spannung")),
                    Container(
                        color: rowColor, child: Text(value["Spg"].toString())),
                  ]),
                  TableRow(children: [
                    Container(color: rowColor, child: Text("Ort")),
                    Container(
                        color: rowColor, child: Text(value["Ort"].toString())),
                  ]),
                  TableRow(children: [
                    Container(color: rowColor, child: Text("Kap")),
                    Container(
                        color: rowColor, child: Text(value["Kap"].toString())),
                  ]),
                  TableRow(children: [
                    Container(color: rowColor, child: Text("Zyklus")),
                    Container(
                        color: rowColor, child: Text(value["Zykl"].toString())),
                  ]),
                  TableRow(children: [
                    Divider(),
                    Divider(),
                  ]),
                ],
              );
            });
          } else {
            return Container();
          }
        } else if (snapshot.hasError) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              )
            ],
          );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const <Widget>[
              SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Läd einträge...'),
              )
            ],
          );
        }
        return Table(
          //crossAxisCount: 6,
          children: children,
        );
      },
//          }
    );
  }
}

class AufzugPage extends StatefulWidget {
  AufzugPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  AufzugPageState createState() => AufzugPageState();
}

class AufzugPageState extends State<AufzugPage> {
  bool _lastInited = false;
  bool _showArbeiten = false;
  Map<String, String> checkboxStates = {};
  Map<String, String> savedText = {};
  Map<String, dynamic> addedTodos = {};

  void writeInLastAFZs(AufzugsArgumente args) async {
    _lastInited = true;
    print("writeInLastAFZs");
    if (Preferences.prefs == null) {
      print("prefs==null");

      await Preferences.initPrefs();
    }
    if (Preferences.prefs.containsKey("lastAFZs")) {
      List<String> lastAFZs = Preferences.prefs.getStringList("lastAFZs");
      if (lastAFZs.contains(args.afzIdx.toString()))
        lastAFZs.remove(args.afzIdx.toString());
      lastAFZs.insert(0, args.afzIdx.toString());
      if (lastAFZs.length > 10) {
        //print("removed: "+lastAFZs[10]);
        lastAFZs.removeAt(10);
      }
      Preferences.prefs.setStringList("lastAFZs", lastAFZs);
    } else {
      Preferences.prefs.setStringList("lastAFZs", [args.afzIdx.toString()]);
    }
  }

  void printFutureResponse(Future<http.Response> response) async {
    print("change get Back");
    print((await response).body);
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  void createNewToDo(String key, String aidx) async {
    String response = await WebComunicater.sendRequest(<String, String>{
      'auth': Preferences.prefs.getString("key"),
      'toDoNewText': addedTodos[key]['text'],
      'AfzIdx': aidx,
      'toDoSet': (addedTodos[key]["checked"] != "").toString(),
    });
    print("create new ToDo" + key);
    print("response: " + response);
    if (isNumeric(response)) {
      addedTodos[key]["idx"] = int.parse(response).toString();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final AufzugsArgumente args = ModalRoute.of(context).settings.arguments;
    if (!_lastInited) writeInLastAFZs(args);
    List<Widget> workWidget = [];

    workWidget.add(
      DataTable(
        headingRowHeight: 0,
        columns: [
          DataColumn(
            label: Text(""),
          ),
          DataColumn(label: Text("")),
        ],
        rows: [
          DataRow(cells: [
            //DataCell(Text("Aufzugsnummer")),
            DataCell(SelectableText("Aufzugsnummer")),
            DataCell(SelectableText(args.aNr)),
          ]),
          DataRow(cells: [
            DataCell(SelectableText("Ort")),
            DataCell(SelectableText(args.aOrt)),
          ]),
          DataRow(cells: [
            DataCell(SelectableText("PLZ")),
            DataCell(SelectableText(args.aPLZ)),
          ]),
          DataRow(cells: [
            DataCell(SelectableText("Straße + Hausnummer")),
            DataCell(SelectableText(args.aStr.toString())),
          ]),
          DataRow(cells: [
            DataCell(SelectableText("Anfahrtszeit")),
            DataCell(SelectableText(args.aFZ)),
          ]),
          DataRow(cells: [
            DataCell(SelectableText("Schlüsselort")),
            DataCell(SelectableText(args.schluessel)),
          ]),
        ],
      ),
    );

    workWidget.add(Divider());

    workWidget.add(AkkuList(args.json));

    workWidget.add(Divider(
        thickness: 3,
        //height: 50,
        color: Colors.black));
    workWidget.addAll([
      Table(
        children: [
          TableRow(children: [
            ElevatedButton(
              child: Text("Arbeiten"),
              style: ElevatedButton.styleFrom(
                primary: Colors.grey[!(_showArbeiten) ? 700 : 500],
                elevation: 20,
                shape: const BeveledRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5))),
              ),
              onPressed: () {
                if (!this._showArbeiten) {
                  this.setState(() {
                    _showArbeiten = true;
                  });
                }
              },
            ),
            ElevatedButton(
              child: Text("To-Dos"),
              style: ElevatedButton.styleFrom(
                primary: Colors.grey[_showArbeiten ? 700 : 500],
                elevation: 10,
                shape: const BeveledRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5))),
              ),
              onPressed: () {
                if (this._showArbeiten) {
                  this.setState(() {
                    _showArbeiten = false;
                  });
                }
              },
            ),
          ])
        ],
      )
    ]);

    workWidget.add(Divider(
        thickness: 3,
        //height: 50,
        color: Colors.black));

    if (this._showArbeiten) {
      workWidget.add(WorkList(args.json));
    } else if (!this._showArbeiten) {
      workWidget.add(ToDoAufzugList(args.json, args.afzIdx));
    } else {
      print(!this._showArbeiten);
      //print(toDoExists);
      //print("keine Arbeit für diesen Aufzug eingetragen");

    }
    //print(toDoMap);

    //print("build AufzugPageState");
    return Scaffold(
      appBar: AppBar(
        title: Text(args.aNr + ", " + args.aStr),
      ),
      body: Center(
        child: ListView(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: workWidget,
        ),
      ),
    );
  }
}

class History extends StatefulWidget {
  History({
    Key key,
  }) : super(key: key);

  @override
  HistoryState createState() => HistoryState();
}

class HistoryState extends State<History> {
  Map<String, String> response;

  Future<List<Widget>> getResponse(String listString) async {
    String response = await WebComunicater.sendRequest(<String, String>{
      'AfzIdxList': listString,
      'auth': Preferences.prefs.getString("key"),
    });
    print("response:" + response);
    response = response.replaceAll("\n", "");
    Map<String, dynamic> responseMap =
        Map<String, dynamic>.from(jsonDecode(response));
    if (responseMap["error"]) {
      return Future.error("Etwas ist schief gelaufen");
    }
    responseMap.remove("error");

    List<Widget> toReturn = [];
    bool even = true;
    Color tablecolor = Colors.grey[300];

    responseMap
      ..forEach((key, value) {
        toReturn.add(AufzugListItem(
          afzIdx: value["afzIdx"].toString(),
          ahnr: value["Ahnr"].toString(),
          anr: value["Anr"].toString(),
          astr: value["Astr"].toString(),
          fKZeit: value["FK_zeit"].toString(),
          ort: value["Ort"].toString(),
          plz: value["plz"].toString(),
          zgTxt: value["Zg_txt"].toString(),
          tablecolor: tablecolor,
        ));

        if (even) {
          tablecolor = Colors.white;
        } else {
          tablecolor = Colors.grey[300];
        }
        even = !even;
      });
    return toReturn;
  }

  @override
  Widget build(BuildContext context) {
    print("Preferences.prefs == null: " +
        (Preferences.prefs == null).toString() +
        "\n!Preferences.prefs.containsKey(\"lastAFZs\")" +
        (!Preferences.prefs.containsKey("lastAFZs")).toString());
    if (Preferences.prefs == null ||
        !Preferences.prefs.containsKey("lastAFZs")) {
      return Text("Der Verlauf ist Leer oder es ist ein Fehler aufgetreten");
    }
    String listString = "";
    Preferences.prefs.getStringList("lastAFZs").forEach((element) {
      listString += element + ",";
    });
    if (listString.length > 0) {
      listString = listString.substring(0, listString.length - 1);
    }
    print("listString: " + listString);
    Future<List<Widget>> response = getResponse(listString);

    return SingleChildScrollView(
      child: FutureBuilder<List<Widget>>(
        future: response,
        builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            children = snapshot.data;
          } else if (snapshot.hasError) {
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              )
            ];
          } else {
            children = const <Widget>[
              SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Läd einträge...'),
              )
            ];
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          );
        },
//          }
      ),
    );
  }
}

//ignore: must_be_immutable
class AufzugListItem extends StatefulWidget {
  Color tablecolor;
  String anr;
  String astr;
  String ahnr;
  String plz;
  String ort;
  String fKZeit;
  String zgTxt;
  String afzIdx;

  AufzugListItem(
      {Key key,
      this.anr,
      this.astr,
      this.ahnr,
      this.plz,
      this.ort,
      this.fKZeit,
      this.zgTxt,
      this.afzIdx,
      this.tablecolor})
      : super(key: key);

  @override
  AufzugListItemState createState() => AufzugListItemState();
}

class AufzugListItemState extends State<AufzugListItem> {
  @override
  Widget build(BuildContext context) {
    TextStyle tableRowTopStyle =
        TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey[900]);
    TextStyle tableRowBottomStyle = TextStyle(
      fontWeight: FontWeight.normal,
    );
    List<Widget> columnChildren = [
      Row(children: [
        Text(
          widget.anr + " ",
          style: tableRowTopStyle,
        ),
        Text(widget.astr + " " + widget.ahnr, style: tableRowTopStyle),
      ]),
      Row(
        children: [
          Text(widget.plz + " ", style: tableRowBottomStyle),
          Text(widget.ort, style: tableRowBottomStyle),
        ],
      ),
      Row(
        children: [
          Text("Anfahrt ", style: tableRowBottomStyle),
          Text(widget.fKZeit, style: tableRowBottomStyle),
        ],
      ),
      //Divider(),
    ];
    if (widget.zgTxt.length > 2) {
      columnChildren.add(Row(
        children: [
          Text("Schlüssel ", style: tableRowBottomStyle),
          Text(widget.zgTxt, style: tableRowBottomStyle),
        ],
      ));
    }

    return Container(
      padding:
          const EdgeInsets.only(right: 20.0, left: 10.0, bottom: 5.0, top: 5.0),
      //padding: const EdgeInsets.only(left: 10.0),
      color: widget.tablecolor,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: new InkWell(
                  child: Column(
                    children: columnChildren,
                  ),
                  onTap: () {
                    SelectElevator.selectElevator(
                        widget.afzIdx,
                        widget.anr,
                        widget.astr + " " + widget.ahnr,
                        widget.plz,
                        widget.ort,
                        widget.fKZeit,
                        widget.zgTxt,
                        context);
                  },
                ),
              ),
              new InkWell(
                child: Icon(
                  Icons.map_outlined,
                  size: 60,
                  color: Colors.blue,
                ),
                onTap: () {
                  launch("https://www.google.de/maps/search/?api=1&query=" +
                      widget.astr +
                      "+" +
                      widget.ahnr +
                      ",+" +
                      widget.plz +
                      "+" +
                      widget.ort);
                },
              ),
            ],
          ),
          //Divider(thickness: 0.0),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        Aufzug.aufzugRoute: (context) => Aufzug(),
      },
      title: 'Bombelczyk',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        //primarySwatch: Colors.green,

        //Color.fromRGBO(0, 77, 170, 1)
      ),
      home: MyHomePage(title: 'Aufzugs Übersicht'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions;

  //String _ipToAsk = '192.168.168.148';
  //String _ipToAsk = 'bombelczyk-aufzuege.de';
  bool _sortDirection = false;
  bool _toDoSortDirection = false;
  bool _toDoShowChecked = false;
  bool _toDoShowUnchecked = true;
  //Socket socket;

  Map<String, dynamic> _responseMap;
  Map<String, dynamic> toDoresponseMap;
  bool _requestError = false;
  int _sort = 1;
  int _toDoSort = 1;
  final _searchController = TextEditingController();

  List<Widget> _tabelle = [Text("")];
  List<Widget> _neaByWidgets = [Text("")];

  @override
  void initState() {
    super.initState();
    checkKey();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    _widgetOptions = <Widget>[

      Column(
        children: <Widget>[

          Container(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              //width:200.0,

              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  refreshTable(value);
                },
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  hintText: 'Suche Aufzuge',
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
    //Flexible(child:
          Row(children: <Widget>[
            Container(
              child:

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                //width:200.0,

                child: DropdownButton<Sorts>(
                  value: Sorts.values[_sort],
                  items:
                      Sorts.values.map<DropdownMenuItem<Sorts>>((Sorts value) {
                    return DropdownMenuItem<Sorts>(
                      value: value,
                      child: Text(value.toString().replaceAll("Sorts.", "")),
                    );
                  }).toList(),
                  onChanged: (Sorts newValue) {
                    _sort = newValue.index;
                    refreshTable(_searchController.text);
                  },
                ),
              ),
            ),
            InkWell(
              child: (_sortDirection)
                  ? Icon(Icons.arrow_downward)
                  : Icon(Icons.arrow_upward),
              onTap: () {
                sortieren(_sort);
              },
            )
          ]),
          new Expanded(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            //padding:const EdgeInsets.fromLTRB(5, 0, 0, 3),
            child: SingleChildScrollView(
                child: Column(
              children: _tabelle,
            )),
          )),

        ],
      ),
      SingleChildScrollView(
        child: Column(
          children: _neaByWidgets,
          //'Hier Kommt so Batterei Zeug hin',
        ),
      ),

      //To Dos Home
      ToDoHome(),

      Column(children: <Widget>[
        new Expanded(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
          //padding:const EdgeInsets.fromLTRB(5, 0, 0, 3),
          child: SingleChildScrollView(
            //  child: Column(
            //children:
            child: History(), //_ToDotabelle,
            //)
          ),
        )),
      ]),
      Text(
        'Vielleicht kommt hier noch irgendwas hin',
      ),
    ];
    //refreshTable("");

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Suche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_pin),
            label: 'In der Nähe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_rounded), //color: Colors.red,),
            label: 'To-Do',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Historie',
          ),
        ],
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        //selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.blueGrey,
        unselectedLabelStyle: TextStyle(
          color: Colors.blueGrey,
          //backgroundColor: Colors.green,
        ),
        //fixedColor: Colors.red,

        selectedItemColor: Colors.blue,

        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 1) {
      getNearby(10);
    }
    /*else if (_selectedIndex == 2) {
      refreshToDoTable(_searchToDoController.text);
    }*/
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      //print('Location services are disabled.');
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        //print('Location permissions are permanently denied, we cannot request permissions.');
        return Future.error(
            'Keine berechtigung um auf Standort zuzugreifen, Wenn Sie diese Feature nutzen möchten ändern sie bitte ihre Einstellungen');
      }

      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        //print('Location permissions are denied');
        return Future.error('Keine berechtigung um auf Standort zuzugreifen');
      }
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Widget createDropDown(int menge, bool working) {
    if (working) {
      _neaByWidgets.add(CircularProgressIndicator());
    }
    //print("create Drop down");
    //print(_neaByWidgets.length);
    if (_neaByWidgets.length == 1) {
      setState(() {
        _neaByWidgets
            .addAll([createDropDown(menge, true), CircularProgressIndicator()]);
      });
    }

    return Row(children: [
      Text("Menge: "),
      DropdownButton<int>(
        value: menge,
        onChanged: (int newValue) {
          //print("set State");
          if (working) {
            //print("working");
            setState(() {
              _neaByWidgets[0] = createDropDown(newValue, true);
              //print("working...");
            });
          } else {
            //print("not working");
            setState(() {
              _neaByWidgets[0] = createDropDown(newValue, true);
            });
          }
          getNearby(newValue);
        },
        items: <int>[10, 20, 50].map<DropdownMenuItem<int>>((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(value.toString()),
          );
        }).toList(),
      )
    ]);
  }

  void getNearby(int menge) async {
    bool error = false;
    String errorMessage;
    SharedPreferences prefs;
    if (Preferences.prefs == null) {
      prefs = await Preferences.initPrefs();
    } else {
      prefs = Preferences.prefs;
    }

    if (_neaByWidgets.length < 2) {
      createDropDown(menge, true);
    }

    if (!prefs.containsKey("key")) {
      //print("Send Without Key");
      AuthKey.wrongKey(context);

      return;
    }
    print("position Start");
    Position pos = await _determinePosition().catchError((e) {
      error = true;
      errorMessage = e;
    });
    if (error) {
      setState(() {
        _neaByWidgets = [
          Icon(
            Icons.not_listed_location_outlined,
            size: 100,
          ),
          Text(
            errorMessage,
            style: TextStyle(fontSize: 20),
          )
        ];
      });
    }

    print("position finished");
    //print(pos);
    double x = pos.latitude;
    double y = pos.longitude;
    String response = await WebComunicater.sendRequest(<String, String>{
      'posX': x.toString(),
      'posY': y.toString(),
      'auth': prefs.getString("key"),
      'anz': menge.toString(),
      //'auth':"12345678910",
      //"sort": _sort.toString(),
      //"sortDirection": _sortDirection.toString(),
    });

    /*http.Response response = await http.post(
      //Uri.https('silas.lan.home', 'BombelApp/index.php'),
      Uri.https(_ipToAsk, 'UpP0UH3nFKMsnJk/index.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'posX': x.toString(),
        'posY': y.toString(),
        'auth': prefs.getString("key"),
        'anz': menge.toString(),
        //'auth':"12345678910",
        //"sort": _sort.toString(),
        //"sortDirection": _sortDirection.toString(),
      }),
    );*/

    String responseStr = response.replaceAll("\n", "");
    //print(responseStr);
    if (responseStr == "false") {
      AuthKey.wrongKey(context);

      return;
    }
    //int dropdownValue = 10;
    Map<String, dynamic> responseMap =
        Map<String, dynamic>.from(jsonDecode(responseStr));
    responseMap.remove("error");

    List<Widget> tmpWidgets = [createDropDown(menge, true)];
    /*[Row(
      children: [
        Text("Menge: "),
        DropdownButton<int>(
        value: menge,
        onChanged: (int newValue) {

          getNearby(newValue);
        },
        items: <int>[10, 20, 50]
            .map<DropdownMenuItem<int>>((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(value.toString()),
          );
        })
            .toList(),
      )]),
    ];*/
    String entfernungsText = "";
    bool even = true;
    Color tablecolor = Colors.grey[300];

    TextStyle tableRowTopStyle =
        TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey[900]);
    TextStyle tableRowBottomStyle = TextStyle(
      fontWeight: FontWeight.normal,
    );
    TextStyle tableRowEntfStyle = TextStyle(
      color: Colors.grey[700],
      fontStyle: FontStyle.italic,
    );

    responseMap.forEach((key, value) {
      try {
        //double dist = double.parse(responseMap["distantz"]);
        double dist = value["distantz"].toDouble();
        if (dist > 1) {
          entfernungsText = value["distantz"].toString() + " km";
        } else {
          entfernungsText = (dist * 1000).toInt().toString() + " m";
        }
        //print("converting worked");
      } on Exception {
        //print("converting Went wrong");
        entfernungsText = value["distantz"].toString() + " km";
      }

      /*tmpWidgets.add(
        Container(
          child:Column(
            children: [
              Row(children: [
                Text(value["Anr"].toString()+" "),
                Text(value["Astr"].toString()+" "+value["Ahnr"].toString()),


              ],),
              Row(children: [
                Text(value["plz"].toString()+" "),
                Text(value["Ort"].toString()),
              ],),
              Divider(),
            ],
          )//Text(value["Anr"].toString()+" "+value["Astr"].toString()+" "+value["Anr"].toString()+" "+value["Ahnr"].toString()+", "+value["plz"].toString()+" "+value["Ort"].toString()+" "),
        )
      );*/

      List<Widget> columnChildren = [
        Row(children: [
          Text(
            value["Anr"].toString() + " ",
            style: tableRowTopStyle,
          ),
          Text(value["Astr"].toString() + " " + value["Ahnr"].toString(),
              style: tableRowTopStyle),
        ]),
        Row(
          children: [
            Text(value["plz"].toString() + " ", style: tableRowBottomStyle),
            Text(value["Ort"].toString(), style: tableRowBottomStyle),
          ],
        ),
        Row(
          children: [
            Text("Anfahrt: ", style: tableRowBottomStyle),
            Text(value["FK_zeit"].toString(), style: tableRowBottomStyle),
          ],
        ),
      ];
      if (value["Zg_txt"].length > 2)
        columnChildren.add(Row(
          children: [
            Text("Schlüssel: ", style: tableRowBottomStyle),
            Text(value["Zg_txt"].toString(), style: tableRowBottomStyle),
          ],
        ));

      columnChildren.add(
          Row(children: [Text(entfernungsText, style: tableRowEntfStyle)]));
      //Divider(),

      tmpWidgets.add(
        Container(
          padding: const EdgeInsets.only(
              right: 20.0, left: 10.0, bottom: 7.0, top: 7.0),
          //padding: const EdgeInsets.only(left: 10.0),
          color: tablecolor,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: new InkWell(
                      child: Column(
                        children: columnChildren,
                      ),
                      //Text(value["Anr"].toString()+" "+value["Astr"].toString()+" "+value["Anr"].toString()+" "+value["Ahnr"].toString()+", "+value["plz"].toString()+" "+value["Ort"].toString()+" "),
                      onTap: () {
                        SelectElevator.selectElevator(
                            value["afzIdx"].toString(),
                            value["Anr"].toString(),
                            value["Astr"].toString() +
                                " " +
                                value["Ahnr"].toString(),
                            value["plz"].toString(),
                            value["Ort"].toString(),
                            value["FK_zeit"].toString(),
                            value["Zg_txt"].toString(),
                            context);
                      },
                    ),
                  ),
                  new InkWell(
                    child: Icon(
                      Icons.map_outlined,
                      size: 60,
                      color: Colors.blue,
                    ),
                    onTap: () {
                      launch("https://www.google.de/maps/search/?api=1&query=" +
                          value["Astr"].toString() +
                          "+" +
                          value["Ahnr"].toString() +
                          ",+" +
                          value["plz"].toString() +
                          "+" +
                          value["Ort"].toString());
                    },
                  ),
                ],
              ),
              //Divider(thickness: 0.0),
            ],
          ),
        ), //Container
      );

      if (even) {
        tablecolor = Colors.white;
      } else {
        tablecolor = Colors.grey[300];
      }
      even = !even;
    });
    setState(() {
      _neaByWidgets = tmpWidgets;
    });

    //print("Hallo");
  }

  void sortieren(int sort) {
    if (_sort == sort) {
      _sortDirection = !_sortDirection;
    } else {
      _sort = sort;
    }
    refreshTable(_searchController.text);
  }

  Future<String> checkKey() async {
    //print("CheckKey:");
    SharedPreferences prefs;
    if (Preferences.prefs == null) {
      prefs = await Preferences.initPrefs();
    } else {
      prefs = Preferences.prefs;
    }

    if (prefs.containsKey("key")) {
      String response = await WebComunicater.sendRequest(<String, String>{
        'auth': prefs.getString("key"),
      });

      /*http.Response response = await http.post(
        //Uri.https('silas.lan.home', 'BombelApp/index.php'),
        Uri.https(_ipToAsk, 'UpP0UH3nFKMsnJk/index.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'auth': prefs.getString("key"),
        }),
      );*/

      //print(prefs.getString("key"));
      String respnse = response.replaceAll("\n", "");
      //print("response:"+respnse);
      if (respnse == "true") return prefs.getString("key");
    }
    //showDialog(context: context,
    AuthKey.wrongKey(context);

    return "";
  }

  refreshToDoTable(String text) async {
    //if (text.length > 2)
    searchToDos(text);

    /*else {
      setState(() {
        //_tabelle = [Text("Geben sie Mindestens 3 Zeichen ein")];
      });
    }*/
  }

  void searchToDos(String search) async {
    SharedPreferences prefs;
    if (Preferences.prefs == null) {
      prefs = await Preferences.initPrefs();
    } else {
      prefs = Preferences.prefs;
    }
    if (!prefs.containsKey("key")) {
      AuthKey.wrongKey(context);

      return;
    }

    String response = await WebComunicater.sendRequest(<String, String>{
      'toDoSearchText': search,
      'auth': prefs.getString("key"),
      "toDoSort": _toDoSort.toString(),
      "sortDirection": _toDoSortDirection.toString(),
      "showChecked": _toDoShowChecked.toString(),
      "showUnchecked": _toDoShowUnchecked.toString(),
    });
    /*print("showChecked: " +
        _toDoShowChecked.toString() +
        "\nshowUnchecked: " +
        _toDoShowUnchecked.toString());
    */
    String responseStr = response.replaceAll("\n", "");
    //print("responseStr:");
    //print(response);
    if (responseStr == "false") {
      AuthKey.wrongKey(context);

      return;
    }
    toDoresponseMap = Map<String, dynamic>.from(jsonDecode(responseStr));
    if (toDoresponseMap["error"]) {
      _requestError = true;
      setState(() {
        //print("setState");
      });
      return;
    }
    _requestError = false;
    toDoresponseMap.remove("error");
    //processToDos();
    setState(() {
      //print("setState");
    });
  }

  void refreshTable(String text) {
    if (text.length > 2)
      search(text);
    else {
      setState(() {
        _tabelle = [Text("Geben sie Mindestens 3 Zeichen ein")];
      });
    }
  }

  void search(String search) async {
    SharedPreferences prefs;
    if (Preferences.prefs == null) {
      prefs = await Preferences.initPrefs();
    } else {
      prefs = Preferences.prefs;
    }
    //print(prefs.getString("key"));
    if (!prefs.containsKey("key")) {
      //print("Send Without Key");
      AuthKey.wrongKey(context);

      return;
    }

    //Uri.https('silas.lan.home', 'BombelApp/index.php'),
    //
    String response = await WebComunicater.sendRequest(<String, String>{
      'search': search,
      'auth': prefs.getString("key"),
      //'auth':"12345678910",
      "sort": _sort.toString(),
      "sortDirection": _sortDirection.toString(),
    });

    String responseStr = response.replaceAll("\n", "");
    //print(responseStr);
    if (responseStr == "false") {
      AuthKey.wrongKey(context);

      return;
    }

    _responseMap = Map<String, dynamic>.from(jsonDecode(responseStr));
    if (_responseMap["error"]) {
      _requestError = true;
      return;
    }
    _requestError = false;
    _responseMap.remove("error");
    processData();
  }

  void processData() {
    if (_requestError) return;

    bool even = true;
    Color tablecolor = Colors.grey[300];
    List<Widget> tmpTabelle = [];


    _responseMap.forEach((key, value) {
      tmpTabelle.add(AufzugListItem(
        afzIdx: value["afzIdx"].toString(),
        ahnr: value["Ahnr"].toString(),
        anr: value["Anr"].toString(),
        astr: value["Astr"].toString(),
        fKZeit: value["FK_zeit"].toString(),
        ort: value["Ort"].toString(),
        plz: value["plz"].toString(),
        zgTxt: value["Zg_txt"].toString(),
        tablecolor: tablecolor,
      ));

      if (even) {
        tablecolor = Colors.white;
      } else {
        tablecolor = Colors.grey[300];
      }
      even = !even;
    });

    setState(() {
      _tabelle = tmpTabelle;
    });
  }
}
