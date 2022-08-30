import 'package:flutter/material.dart';

import 'helper.dart';
import 'package:http/http.dart' as http;
import 'web_comunicater.dart';
import 'to_do_aufzugs_list.dart';
import 'work_list.dart';
import 'akku_list.dart';
import 'add_to_tour_dialog.dart';

class AufzugWidget extends StatelessWidget {
  static const aufzugRoute = '/aufzugRoute';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AufzugPage(title: 'Aufzugs Übersicht');
  }
}

class AufzugPage extends StatefulWidget {
  AufzugPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  AufzugPageState createState() => AufzugPageState();
}

class AufzugPageState extends State<AufzugPage> {
  bool _lastInited = false;
  bool _showArbeiten = false;
  Map<String, String> checkboxStates = {};

  //Map<String, String> savedText = {};
  Map<String, dynamic> addedTodos = {};
  Widget? toDoList;
  Widget? arbeitsList;

  void writeInLastAFZs(AufzugsArgumente args) async {
    _lastInited = true;

    if (Preferences.prefs == null) {
      print("prefs==null");

      await Preferences.initPrefs();
    }
    if (Preferences.prefs!.containsKey("lastAFZs")) {
      List<String> lastAFZs = Preferences.prefs!.getStringList("lastAFZs")!;
      if (lastAFZs.contains(args.afzIdx.toString()))
        lastAFZs.remove(args.afzIdx.toString());
      lastAFZs.insert(0, args.afzIdx.toString());
      if (lastAFZs.length > 10) {
        //print("removed: "+lastAFZs[10]);
        lastAFZs.removeAt(10);
      }
      Preferences.prefs!.setStringList("lastAFZs", lastAFZs);
    } else {
      Preferences.prefs!.setStringList("lastAFZs", [args.afzIdx.toString()]);
    }
  }

  void printFutureResponse(Future<http.Response> response) async {}

  bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  void createNewToDo(String key, String aidx) async {
    String response = await WebComunicater.sendRequest(<String, String>{
      'auth': Preferences.prefs!.getString("key")!,
      'toDoNewText': addedTodos[key]['text'],
      'AfzIdx': aidx,
      'toDoSet': (addedTodos[key]["checked"] != "").toString(),
    });
    if (isNumeric(response)) {
      addedTodos[key]["idx"] = int.parse(response).toString();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final AufzugsArgumente args =
        ModalRoute.of(context)!.settings.arguments as AufzugsArgumente;
    if (this.toDoList == null) {
      this.toDoList = ToDoAufzugList(args.json, args.afzIdx);
    }
    if (this.arbeitsList == null) {
      this.arbeitsList = WorkList(args.json);
    }
    if (!_lastInited) writeInLastAFZs(args);
    List<Widget?> workWidget = [];

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
      workWidget.addAll([this.arbeitsList]);
    } else if (!this._showArbeiten) {
      workWidget.add(this.toDoList);
    } else {
      //print(toDoExists);
      //print("keine Arbeit für diesen Aufzug eingetragen");

    }
    //print(toDoMap);

    //print("build AufzugPageState");
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Flexible(
            child: Container(
              //padding: EdgeInsets.only(right: 5),
              child: Text(
                args.aNr + ", " + args.aStr,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Container(
            child: InkWell(
              child: Icon(Icons.add_location_alt_sharp),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AddToTourDialog(args.toMap());
                    });
              },
            ),
          ),
        ]),
      ),
      body: Center(
        child: ListView.builder(
          cacheExtent: workWidget.length * 200.0,
          physics: ClampingScrollPhysics(),
          shrinkWrap: true,
          itemCount: workWidget.length,
          itemBuilder: (context, index) {
            //final count = index + 1;
            return workWidget[index]!;
          },
          //children: workWidget,
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          //children: workWidget,
        ),
      ),
    );
  }
}
