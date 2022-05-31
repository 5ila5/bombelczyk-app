import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'key_checker.dart';
import 'auto_key.dart';
import 'web_comunicater.dart';
import 'dart:convert';
import 'aufzug_list_item.dart';


enum Sorts {
  Aufzugsnummer,
  Strasse,
  Postleitzahl,
  Ort,
  Anfahrtszeit,
}

class Suche extends StatefulWidget {
  bool showMapIcon = true;
  Function customOnclick;
  Suche({
    Key key,
    this.showMapIcon=true,
    this.customOnclick,
  }) : super(key: key);

  @override
  SucheState createState() => SucheState();
}

class SucheState extends State<Suche> {
  final _searchController = TextEditingController();
  Map<String, dynamic> _responseMap;

  List<Widget> _tabelle = [Text("")];
  bool _sortDirection = false;
  bool _requestError = false;
  int _sort = 1;

  void search(String search) async {
    //Uri.https('silas.lan.home', 'BombelApp/index.php'),
    //
    String response = await WebComunicater.sendRequest(<String, String>{
      'search': search,
      //'auth':"12345678910",
      "sort": _sort.toString(),
      "sortDirection": _sortDirection.toString(),
    });
    if (response == null) {
      AuthKey.wrongKey(context);
      return;
    }

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
        showMapIcon: widget.showMapIcon,
        customOnclick: widget.customOnclick,
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
  void refreshTable(String text) {
    if (text.length > 2)
      search(text);
    else {
      setState(() {
        _tabelle = [Text("Geben sie Mindestens 3 Zeichen ein")];
      });
    }
  }
  void sortieren(int sort) {
    if (_sort == sort) {
      _sortDirection = !_sortDirection;
    } else {
      _sort = sort;
    }
    refreshTable(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }

  @override
  void initState() {
    super.initState();
    KeyChecker.checkKey(context);
  }
}