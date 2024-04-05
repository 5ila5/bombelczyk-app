import 'package:flutter/material.dart';
import 'dart:convert';

class AkkuList extends StatefulWidget {
  AkkuList(this.response, {Key? key}) : super(key: key);
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
        List<TableRow> children = [];
        if (snapshot.hasData) {
          //print("snapshot.data");
          //print(snapshot.data);
          //children = snapshot.data;
          Map<String, dynamic> responseMap =
              Map<String, dynamic>.from(jsonDecode(snapshot.data!));
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
