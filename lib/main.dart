import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:async';

import 'package:url_launcher/url_launcher.dart';

//import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import 'dart:developer' as developer;

import 'package:geolocator/geolocator.dart';
import 'aufzug_page.dart';
import 'helper.dart';
import 'to_do_home.dart';
import 'history.dart';
import 'auto_key.dart';
import 'web_comunicater.dart';
import 'aufzug_list_item.dart';







void main() {
  runApp(MyApp());
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
              child: Padding(
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
                            value["AfzIdx"].toString(),
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
        afzIdx: value["AfzIdx"].toString(),
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
