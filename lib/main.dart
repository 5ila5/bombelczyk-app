import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:http/io_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'dart:developer' as developer;

//import 'package:encrypt/encrypt.dart' as encrypt;
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';

enum Sorts {
  Aufzugsnummer,
  Strasse,
  Postleitzahl,
  Ort,
  Anfahrtszeit,
}

/*class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}*/

void main() {
  //HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

class webComunicater {
  //test
  static final String _ipToAsk = 'bombelczyk-aufzuege.de';

  static Future<http.Response> sendRequest(Map<String, String> body,
      {bool login = false}) async {
    return await http.post(
      //Uri.https('silas.lan.home', 'BombelarApp/index.php'),
      Uri.https(_ipToAsk,
          'UpP0UH3nFKMsnJk2/' + ((login) ? 'login.php' : 'index.php')),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );
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
  final String json;
  final String AfzIdx;
  final String aNr;
  final String aStr;
  final String aPLZ;
  final String aOrt;
  final String aFZ;
  final String schluessel;

  AufzugsArgumente(this.AfzIdx, this.aNr, this.json, this.aStr, this.aPLZ,
      this.aOrt, this.aFZ, this.schluessel);
}

class Aufzug extends StatelessWidget {
  static const aufzugRoute = '/aufzugRoute';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //print("build Aufzug");
    return AufzugPage(title: 'Aufzugs Übersicht');
    /*
      appBar: AppBar(
        title: Text("widget"),
      ),
      body: Center(
        child: Text("hi"),
      ),
      );
      */
    //);
  }
}

class AufzugPage extends StatefulWidget {
  AufzugPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  AufzugPageState createState() => AufzugPageState();
}

class AufzugPageState extends State<AufzugPage> {
  bool _showArbeiten = false;
  Map<String, String> checkboxStates = {};
  Map<String, String> savedText = {};
  Map<String,dynamic> addedTodos={};


  void printFutureResponse(Future<http.Response> response) async {
    print("change get Back");
    print((await response).body);
  }


  void switchToDo_Arbeiten(bool arbeiten) {
    this._showArbeiten = arbeiten;

    this.setState(() {});
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  void createNewToDo(String key, String aidx) async{
     http.Response response = await webComunicater.sendRequest(<String, String>{
      'auth': Preferences.prefs.getString("key"),
      'toDoNewText': addedTodos[key]['text'],
       'AfzIdx': aidx,
       'toDoSet': (addedTodos[key]["checked"]!="").toString(),
    });
     print("create new ToDo"+key);
     print("response: "+response.body);
     if (isNumeric(response.body)){
       addedTodos[key]["idx"] = int.parse(response.body).toString();
     }
     setState(() {

     });
  }

  @override
  Widget build(BuildContext context) {
    final AufzugsArgumente args = ModalRoute
        .of(context)
        .settings
        .arguments;
    //Map<String, dynamic> _responseMap = Map<String, dynamic>.from(jsonDecode(args.json));
    List<Widget> workWidget = [];
    //developer.log("args.json:"+args.json);

    Map<String, dynamic> responseMap =
    Map<String, dynamic>.from(jsonDecode(args.json));
    Map<String, dynamic> arbeitMap;
    Map<String, dynamic> toDoMap;
    bool workExists = false;
    bool toDoExists = false;

    //print('responseMap["1"]');
    //print(responseMap["1"]);
    if (responseMap["1"] != "false") {
      arbeitMap = responseMap["1"];
      workExists = true;
    }
    //print('responseMap["2"]');
    //print(responseMap["2"]);
    if (responseMap["2"] != "false") {
      toDoMap = responseMap["2"];
      toDoExists = true;
    }
    //print("arbeitMap");
    //print(arbeitMap);

    List<TableRow> akkuWiegetListRows = [];

    if (responseMap["0"].runtimeType == String ||
        responseMap["0"]["error"] == "true") {
      //print("keine Akkus Für diesen Aufzug eingetragen");
    } else {
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
        akkuWiegetListRows.addAll(
          [
            TableRow(children: [
              Container(color: rowColor, child: Text("Menge")),
              Container(
                  color: rowColor, child: Text(value["Menge"].toString())),
            ]),
            TableRow(children: [
              Container(color: rowColor, child: Text("Letzter Wchsel")),
              Container(
                  color: rowColor, child: Text(value["TauschTag"].toString())),
            ]),
            TableRow(children: [
              Container(color: rowColor, child: Text("Spannung")),
              Container(color: rowColor, child: Text(value["Spg"].toString())),
            ]),
            TableRow(children: [
              Container(color: rowColor, child: Text("Ort")),
              Container(color: rowColor, child: Text(value["Ort"].toString())),
            ]),
            TableRow(children: [
              Container(color: rowColor, child: Text("Kap")),
              Container(color: rowColor, child: Text(value["Kap"].toString())),
            ]),
            TableRow(children: [
              Container(color: rowColor, child: Text("Zyklus")),
              Container(color: rowColor, child: Text(value["Zykl"].toString())),
            ]),
            TableRow(children: [
              Divider(),
              Divider(),
            ]),
          ],
        );
      });
    }

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

    if (akkuWiegetListRows.length > 0) {
      workWidget.add(
        Table(
          //crossAxisCount: 6,
          children: akkuWiegetListRows,
        ),
      );
    }

    workWidget.add(Divider(thickness: 3, height: 50, color: Colors.black));
    workWidget.addAll([
      Table(
        children: [
          TableRow(children: [
            InkWell(
              child: Text("Arbeiten"),
              onTap: () {
                if (!this._showArbeiten) {
                  this.setState(() {
                    _showArbeiten = true;
                  });
                }
              },
            ),
            InkWell(
              child: Text("To-Dos"),
              onTap: () {
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

    workWidget.add(Divider(thickness: 3,
        //height: 50,
        color: Colors.black));

    IconData icon; //= Icons.check_box;
    if (this._showArbeiten && workExists) {
      arbeitMap.remove("error");
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

        List<String> mitarbeiterList = value["MitarbeiterName"].split(",");
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

        workWidget.add(
          Table(
            //border: TableBorder.all(),
            //headingRowHeight: 0,
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
              /*TableRow(
                children: [
                  Text("Akkutausch"),
                  Icon(icon),

                        //Text(value["dat"])),
                  ],
              ),*/
            ],
          ),
        );
        workWidget.add(Divider(thickness: 3, color: Colors.grey));
      });
    } else if (!this._showArbeiten && toDoExists) {
      print("TO DOS");
      toDoMap.remove("error");

      Map<String,TextEditingController> textController={};


      workWidget.addAll([
        InkWell(
          child: Icon(Icons.add, size:40,color:Colors.blue),
          onTap: () {
            int newKey = 1000;
            while (toDoMap.containsKey(newKey.toString())) {
              newKey++;
            }
            DateTime now = DateTime.now();
            DateFormat formatter = DateFormat(
                'yyyy-MM-dd HH:mm:ss');
            String formatted = formatter.format(now);
            addedTodos[newKey.toString()]=<String,String>{
              "created": formatted,
              "checked": "",
              "text":"",
              //"new": "new",
            };
            print("added "+newKey.toString() +" addedTodo:" +addedTodos.toString());

            setState(() {
            });




          },
        ),
        Divider(thickness: 1, color:Colors.grey),
      ]);
      //addedTodos.addAll(toDoMap);
      Map<String,dynamic> newMap={};
      newMap.addAll(addedTodos);
      newMap.addAll(toDoMap);
      toDoMap=newMap;
      //toDoMap=addedTodos;
      print("addedTodos"+addedTodos.toString());
      print("newMap"+newMap.toString());
      print("toDoMap"+toDoMap.toString());

      toDoMap.forEach((key, value) {
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
        print("|" + toDoMap[key]["checked"] + "|");

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
          textController[key] = TextEditingController(text:savedText[key]);
          print(savedText[key]);
          print(textController[key].text);

        } else {
          textController[key]=TextEditingController(text: value["text"]);
        }




        workWidget.add(
          Table(
              columnWidths: {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(6),
              },

              children: [
          TableRow(children: [
          Checkbox(
          value: (checkBoxVal),
          onChanged: (bool newValue) {
            DateTime now = DateTime.now();
            DateFormat formatter = DateFormat(
                'yyyy-MM-dd HH:mm:ss');
            String formatted = formatter.format(now);

            //printFutureResponse(
            if (!value.containsKey("idx")) {
              addedTodos[key]["checked"] = (newValue)? formatted:"";
              if (newValue) {
                addedTodos[key]["text"] = textController[key].text;
                createNewToDo(key.toString(),args.AfzIdx);
              }
            } else {
              webComunicater.sendRequest(<String, String>{
                'auth': Preferences.prefs.getString("key"),
                'toDoSet': newValue.toString(),
                'toDoIdx': value['idx'].toString(),
              }
              );
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
        Column(children: [
          (checkBoxVal)?
          SelectableText(textController[key].text):
        Column(children: [
          TextField(
            controller: textController[key],
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: const InputDecoration(
                //border: OutlineInputBorder(),
                //hintText: 'Enter a search term'
            ),
          ),
          Row(
            children:[
            InkWell(
            child: Icon(Icons.save_outlined,size:40,color:Colors.green),
            onTap: (){

              if (!value.containsKey("idx")) {
                addedTodos[key]["text"] = textController[key].text;
                createNewToDo(key.toString(),args.AfzIdx);
              } else {
                webComunicater.sendRequest(<String, String>{
                  'auth': Preferences.prefs.getString("key"),
                  'toDoNewText': textController[key].text,
                  'toDoIdx': value['idx'].toString(),
                });
              }
              setState(() {
                savedText[key]=textController[key].text;
              });
            }
          ),
          InkWell(
            child: Icon(Icons.cancel,size:40, color:Colors.red),
            onTap: (){setState(() {
            });},
          ),]),]),

        ],),


        ]),
        ]),
        );
        workWidget.add(
        Divider(thickness: 1, color:Colors.grey)
        );
      });
    } else {
      print(!this._showArbeiten);
      print(toDoExists);
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

        /*
        child: ElevatedButton(
          child: Text('Open route'),
          onPressed: () {
            // Navigate to second route when tapped.
          },
        ),*/
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
  //String codeDialog ="";
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions;

  //String _ipToAsk = '192.168.168.148';
  String _ipToAsk = 'bombelczyk-aufzuege.de';
  bool _sortDirection = false;
  Socket socket;
  int _counter = 0;
  Map<String, dynamic> _responseMap;
  bool _requestError = false;
  int _sort = 1;
  final _searchController = TextEditingController();
  final _passwordController = TextEditingController();
  List<Widget> _tabelletop;
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
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
              //width:200.0,

              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  refreshTable(value);
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
          Row(children: <Widget>[
            Container(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
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
                  //<sorts>[10, 20, 50]
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
                /*GridView.count(
                mainAxisSpacing: 10,
              crossAxisCount: 6,
              children: _tabelle //[Text("hallo"),Text("hallo2"),Text("hallo3"),Text("hallo4"),Text("hallo5"),Text("hallo6"),Text("hallo7"),Text("hallo8")]
            ),*/
              )),
        ],
      ),
      SingleChildScrollView(
        child: Column(
          children: _neaByWidgets,
          //'Hier Kommt so Batterei Zeug hin',
        ),
      ),
      Text(
        'Vielleicht kommt hier noch irgendwas hin',
      ),
    ];
    //refreshTable("");
    _tabelletop = [
      InkWell(
        onTap: () {
          sortieren(0);
        },
        child: Text("Aufzugsnummer",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      InkWell(
        onTap: () {
          sortieren(1);
        },
        child: Text("Straße", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      //Text("Hausnummer",style: TextStyle(fontWeight:FontWeight.bold)),
      InkWell(
        onTap: () {
          sortieren(2);
        },
        child: Text("PLZ", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      InkWell(
        onTap: () {
          sortieren(3);
        },
        child: Text("Ort", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      InkWell(
        onTap: () {
          sortieren(4);
        },
        child: Text("Fahrzeit", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      InkWell(
        child: Icon(Icons
            .map_outlined), //Text("maps",style: TextStyle(fontWeight:FontWeight.bold)),
      ),
    ];

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
            label: 'Aufzugssuche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_pin),
            label: 'In meiner Nähe',
          ),
          /*BottomNavigationBarItem(
            icon: Icon(Icons.elevator_outlined),
            label: 'School',
          ),*/
        ],
        currentIndex: _selectedIndex,
        //selectedItemColor: Colors.amber[800],
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 1) {
      getNearby(10);
    }
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
      wrongKey();
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
    http.Response response = await webComunicater.sendRequest(<String, String>{
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

    String responseStr = response.body.replaceAll("\n", "");
    //print(responseStr);
    if (responseStr == "false") {
      wrongKey();
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
    Color Tablecolor = Colors.grey[300];

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
          color: Tablecolor,
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
                        selectElevator(
                            value["AfzIdx"].toString(),
                            value["Anr"].toString(),
                            value["Astr"].toString() +
                                " " +
                                value["Ahnr"].toString(),
                            value["plz"].toString(),
                            value["Ort"].toString(),
                            value["FK_zeit"].toString(),
                            value["Zg_txt"].toString());
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
        Tablecolor = Colors.white;
      } else {
        Tablecolor = Colors.grey[300];
      }
      even = !even;

      /*new InkWell(
        child: Text(),
        onTap: () {
          selectElevator(value["AfzIdx"].toString(), value["Anr"].toString(), map2["Astr"].toString(), value["plz"].toString(), value["Ort"].toString(), value["FK_zeit"].toString());
        },
      )*/
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

  void setKey() async {
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
      wrongKey();
      return;
    }


    http.Response response = await webComunicater.sendRequest(
        <String, String>{ 'password': pass}, login: true);

    /*http.Response response = await http.post(
      //Uri.https('silas.lan.home', 'BombelApp/index.php'),
      Uri.https(_ipToAsk, 'UpP0UH3nFKMsnJk/login.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'password': pass,
      }),
    );*/

    //print("test1");
    String respnse = response.body.replaceAll("\n", "");
    //print("test2");
    //print("response:"+respnse+"|");
    //print("response:"+respnse.length.toString());
    if (respnse == "false" || respnse.length != 32) {
      //print("false:");
      wrongKey();
      return;
    }
    //print("keySet:");
    prefs.setString("key", respnse);
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
      http.Response response = await webComunicater.sendRequest(
          <String, String>{
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
      String respnse = response.body.replaceAll("\n", "");
      //print("response:"+respnse);
      if (respnse == "true") return prefs.getString("key");
    }
    //showDialog(context: context,
    wrongKey();
    return "";
  }

  void wrongKey() {
    //print("wrongKey:");
    _displayTextInputDialog(context);
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Passwort:'),
            content: TextField(
              onSubmitted: (value) {
                setKey();
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
                  setState(() {
                    //codeDialog = valueText;
                    setKey();
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
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
      wrongKey();
      return;
    }


    //Uri.https('silas.lan.home', 'BombelApp/index.php'),
    //
    http.Response response = await webComunicater.sendRequest(<String, String>{
      'search': search,
      'auth': prefs.getString("key"),
      //'auth':"12345678910",
      "sort": _sort.toString(),
      "sortDirection": _sortDirection.toString(),
    });

    /*http.Response response = await http.post(
      Uri.https(_ipToAsk, 'UpP0UH3nFKMsnJk/index.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'search': search,
        'auth': prefs.getString("key"),
        //'auth':"12345678910",
        "sort": _sort.toString(),
        "sortDirection": _sortDirection.toString(),
      }),
    );*/
    //print(response.toString());
    //print(response.body);

    /*//print(jsonEncode(<String, String>{
      'search': search,
      'auth': prefs.getString("key"),
      "sort": _sort.toString(),
      "sortDirection": _sortDirection.toString(),
    }));*/

    String responseStr = response.body.replaceAll("\n", "");
    print(responseStr);
    if (responseStr == "false") {
      wrongKey();
      return;
    }

    //print(jsonDecode(respnse)["10"]["Anr"]);

    //print(jsonDecode(respnse).runtimeType);

    //print("HALLLLOOO");
    _responseMap = Map<String, dynamic>.from(jsonDecode(responseStr));
    //print("HALLLLOOO2");
    //print(_responseMap);
    //print("\n\n\n");
    //print("\n\n\n");
    //print("\n\n\n");
    if (_responseMap["error"]) {
      _requestError = true;
      return;
    }
    _requestError = false;
    _responseMap.remove("error");
    //print(_responseMap);
    processData();
  }

  void processData() {
    if (_requestError) return;

    bool even = true;
    Color Tablecolor = Colors.grey[300];

    Map<String, dynamic> map2;
    Map<String, dynamic> map2Copy;
    List<Widget> tmpTabelle = [];
    TextStyle tableRowTopStyle =
    TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey[900]);
    TextStyle tableRowBottomStyle = TextStyle(
      fontWeight: FontWeight.normal,
    );

    _responseMap.forEach((key, value) {
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
          color: Tablecolor,
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
                        selectElevator(
                            value["AfzIdx"].toString(),
                            value["Anr"].toString(),
                            value["Astr"].toString() +
                                " " +
                                value["Ahnr"].toString(),
                            value["plz"].toString(),
                            value["Ort"].toString(),
                            value["FK_zeit"].toString(),
                            value["Zg_txt"].toString());
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
        Tablecolor = Colors.white;
      } else {
        Tablecolor = Colors.grey[300];
      }
      even = !even;

      /*
      //print("value"+key+":");
      //print(value);
      //print(value.runtimeType);
      map2Copy = Map<String, dynamic>.from(value);
      map2 = Map<String, dynamic>.from(map2Copy);

      map2Copy.forEach((key2, value2) {
        if (key2=="Astr") {
          map2["Astr"] += " "+map2["Ahnr"];
          map2.remove("Ahnr");
        }
      });

      map2.remove("AfzIdx");

      map2.forEach((key2, value2) {
        tmpTabelle.add(
            //Text(value2.toString())
          new InkWell(
          child: Text(value2.toString()),
            onTap: () {
              selectElevator(value["AfzIdx"].toString(), value["Anr"].toString(), map2["Astr"].toString(), value["plz"].toString(), value["Ort"].toString(), value["FK_zeit"].toString());
            },
          )
        );
        //print(value2);
      });
      tmpTabelle.add(
        new InkWell(
          //child: Text("maps"),
          child: Icon(Icons.map_outlined),
          onTap: () {
            launch("https://www.google.de/maps/search/?api=1&query="+value["Astr"].toString()+"+"+value["Ahnr"].toString()+",+"+value["plz"].toString()+"+"+value["Ort"].toString());
          },
        )
      );
 */
    });

    //tmpTabelle.insertAll(0, _tabelletop);
    setState(() {
      _tabelle = tmpTabelle;
    });

    //return jsonDecode(respnse);

    //print(response.headers);
    //print(response.request);
  }

  void selectElevator(String AfzIdx, String nr, String str, String pLZ,
      String ort, String fZ, String schluessel) async {
    SharedPreferences prefs;
    if (Preferences.prefs == null) {
      prefs = await Preferences.initPrefs();
    } else {
      prefs = Preferences.prefs;
    }
    //print(nr);

    http.Response response = await webComunicater.sendRequest(<String, String>{
      'AfzIdx': AfzIdx,
      'auth': prefs.getString("key"),
    });
    /*http.Response response = await http.post(
      //Uri.https('silas.lan.home', 'BombelApp/index.php'),
      Uri.https(_ipToAsk, 'UpP0UH3nFKMsnJk/index.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'AfzIdx': AfzIdx,
        'auth': prefs.getString("key"),
      }),
    );*/
    String responseStr = response.body.replaceAll("\n", "");
    //print("responsStr:"+responseStr);
    //print("test");
    //print(responseStr);
    //AufzugsArgumente(nr, responseStr);
    Navigator.pushNamed(
      context,
      Aufzug.aufzugRoute,
      //MaterialPageRoute(builder: (context) => Aufzug()),
      arguments: AufzugsArgumente(
          AfzIdx,
          nr,
          responseStr,
          str,
          pLZ,
          ort,
          fZ,
          schluessel),
    );
  }
}
