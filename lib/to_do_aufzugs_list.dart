import 'package:flutter/material.dart';
import 'dart:convert';
import 'aufzug_to_do.dart';

class ToDoAufzugList extends StatefulWidget {
  ToDoAufzugList(this.response, this.afzIdx, {Key key}) : super(key: key);
  final Future<String> response;
  final String afzIdx;

  @override
  ToDoAufzugListState createState() => ToDoAufzugListState();
}

class ToDoAufzugListState extends State<ToDoAufzugList> {
  Widget aufzugToDo;
  @override
  Widget build(BuildContext context) {
    if (aufzugToDo != null) {
      return aufzugToDo;
    }
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
            toDoMap = responseMap["2"];
            toDoMap.remove("error");
          } else {
            toDoMap = {};
          }
          this.aufzugToDo = AufzugToDo(afzIdx: widget.afzIdx, toDoMap: toDoMap);
          return this.aufzugToDo;
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
