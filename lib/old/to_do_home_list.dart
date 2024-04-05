import 'package:flutter/material.dart';
import 'aufzug_to_do.dart';
import 'helper.dart';

class ToDoHomeList extends StatefulWidget {
  final Map<String, dynamic>? toDoresponseMap;
  //String afzIdx;
  final bool allExpanded;

  ToDoHomeList({this.toDoresponseMap, this.allExpanded = false, Key? key})
      : super(key: key);

  @override
  ToDoHomeListState createState() => ToDoHomeListState();
}

class ToDoHomeListState extends State<ToDoHomeList> {
  Map<String, bool> expandedToDos = {};
  Map<String, Widget> allreadyExpanded = {};

  @override
  Widget build(BuildContext context) {
    if (widget.toDoresponseMap == null ||
        (widget.toDoresponseMap!.containsKey("error") &&
            widget.toDoresponseMap!.containsKey("error") == true))
      return Text("Für angegebene Parameter nichts Gefunden");
    bool even = true;
    Color? tablecolor = Colors.grey[300];

    List<Widget> tmpTabelle = [];
    TextStyle tableRowTopStyle =
        TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey[900]);
    TextStyle tableRowBottomStyle = TextStyle(
      fontWeight: FontWeight.normal,
    );
    //toDoresponseMap.
    widget.toDoresponseMap!.forEach((key, value) {
      value["todos"].remove("error");

      bool expanded = (expandedToDos.containsKey(value["AfzIdx"].toString()) &&
              expandedToDos[value["AfzIdx"].toString()]!) ||
          widget.allExpanded;

      if (expanded &&
          !allreadyExpanded.containsKey(value["AfzIdx"].toString())) {
        allreadyExpanded[value["AfzIdx"].toString()] = AufzugToDo(
            afzIdx: value["AfzIdx"].toString(), toDoMap: value["todos"]);
      }

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
              right: 20.0, left: 2.0, bottom: 5.0, top: 5.0),
          //padding: const EdgeInsets.only(left: 10.0),
          color: tablecolor,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: new InkWell(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                              expanded
                                  ? Icons.keyboard_arrow_down
                                  : Icons.keyboard_arrow_up,
                              color: Colors.blue),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 0, left: 5.0, bottom: 0, top: 0),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: columnChildren,
                          ),
                        ],
                      ),
                      onTap: () {
                        if (expanded) {
                          expandedToDos[value["AfzIdx"].toString()] = false;
                        } else {
                          expandedToDos[value["AfzIdx"].toString()] = true;
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
                ],
              ),
              (expanded)
                  ? allreadyExpanded[value["AfzIdx"].toString()]!
                  : Text(""),
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

    return Column(
      children: tmpTabelle,
    );
  }
}
