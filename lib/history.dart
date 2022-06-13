import 'package:flutter/material.dart';
import 'web_comunicater.dart';
import 'helper.dart';
import 'dart:convert';
import 'aufzug_list_item.dart';

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
    //print("response:" + response);
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

    Future<List<Widget>> response = getResponse(listString);

    return Center(
        child: SingleChildScrollView(
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
    ));
  }
}
