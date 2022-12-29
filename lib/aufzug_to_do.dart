import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'web_comunicater.dart';
import 'helper.dart';
import 'package:flutter/services.dart';

class AufzugToDo extends StatefulWidget {
  Map<String, dynamic>? toDoMap;
  final String? afzIdx;

  AufzugToDo({this.afzIdx, this.toDoMap, Key? key}) : super(key: key);

  @override
  AufzugToDoState createState() => AufzugToDoState();
}

class AufzugToDoState extends State<AufzugToDo> {
  //Map <String,dynamic> toDoMap=Widget.;
  Map<String, dynamic> addedTodos = {};
  Map<String, String> checkboxStates = {};

  //Map<String, String> savedText = {};
  //List<String> removedToDoIdxs = [];
  DateFormat readableTimeFormat = DateFormat('dd.MM.yy HH:mm');

  bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }

  String germanDateTime(String inputStr) {
    DateTime parsedDate = DateTime.parse(inputStr);
    return this.readableTimeFormat.format(parsedDate);
  }

  void deleteToDo(Future<String?> alertResponse, String idx) async {
    String? response = await alertResponse;
    if (response != "OK") return;
    WebComunicater.sendRequest(<String, String>{
      'auth': Preferences.prefs!.getString("key")!,
      'removeToDoIdx': idx,
    });

    //this.savedText.remove(idx);
    this.checkboxStates.remove(idx);
    this.addedTodos.remove(idx);
    widget.toDoMap!.removeWhere((key, value) => value["idx"].toString() == idx);

    setState(() {});
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
    widget.toDoMap!.addAll({key: addedTodos[key]});
    addedTodos.remove(key);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Map<String, TextEditingController> textController = {};

    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    List<Widget> widgetList = [
      InkWell(
        child: Icon(Icons.add, size: 40, color: Colors.blue),
        onTap: () {
          int newKey = 1000;
          while (widget.toDoMap!.containsKey(newKey.toString())) {
            newKey++;
          }

          String formatted = formatter.format(now);
          addedTodos[newKey.toString()] = <String, String>{
            "created": formatted,
            "checked": "",
            "text": "",
            //"new": "new",
          };

          setState(() {});
        },
      ),
      Divider(thickness: 1, color: Colors.grey),
    ];
    //addedTodos.addAll(toDoMap);
    Map<String, dynamic> newMap = {};
    newMap.addAll(addedTodos);
    newMap.addAll(widget.toDoMap!);
    widget.toDoMap = newMap;
    //toDoMap=addedTodos;
    //print("addedTodos" + addedTodos.toString());
    //print("newMap" + newMap.toString());
    //print("toDoMap" + widget.toDoMap.toString());

    widget.toDoMap!.forEach((key, value) {
      if (value["created"] == null) {
        value["created"] = "";
      }
      if (value["checked"] == null) {
        value["checked"] = "";
      }
      if (value["text"] == null) {
        value["text"] = "";
      }

      //print("|" + value["text"] + "|");

      bool checkBoxVal;
      if (checkboxStates.containsKey(key)) {
        checkBoxVal = (checkboxStates[key] != "");
      } else {
        checkBoxVal = value["checked"] != "" &&
            value["checked"] != "0000-00-00 00:00:00" &&
            value["checked"] != "NULL";
      }

      textController[key] = TextEditingController(text: value["text"]);
      //}

      Widget deleteButton = InkWell(
          child: Icon(
            Icons.delete_forever_outlined,
            color: Colors.red,
            size: 40,
          ),
          onTap: () {
            HapticFeedback.lightImpact();
            deleteToDo(
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Löschen?'),
                    content: const Text(
                        'bist du Dir sicher, dass du diesen Eintrag Löschen möchtest?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text('Abbrechen'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text(
                          'Ja, Löschen',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                value["idx"].toString());
          });
      widgetList.add(
        Table(columnWidths: {
          0: FlexColumnWidth(1.19),
          1: FlexColumnWidth(6),
        }, children: [
          TableRow(children: [
            Column(children: [
              Checkbox(
                value: (checkBoxVal),
                onChanged: (bool? newValue) {
                  DateTime now = DateTime.now();
                  DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
                  String formatted = formatter.format(now);

                  //printFutureResponse(
                  if (!value.containsKey("idx")) {
                    addedTodos[key]["checked"] = newValue! ? formatted : "";
                    if (newValue) {
                      addedTodos[key]["text"] = textController[key]!.text;
                      createNewToDo(key.toString(), widget.afzIdx!);
                    }
                  } else {
                    WebComunicater.sendRequest(<String, String>{
                      'auth': Preferences.prefs!.getString("key")!,
                      'toDoSet': newValue.toString(),
                      'toDoIdx': value['idx'].toString(),
                    });
                  }
                  setState(() {
                    if (checkBoxVal) {
                      print("set " + key.toString() + " to False");
                      checkboxStates[key] = "";
                    } else {
                      checkboxStates[key] = formatted;
                    }
                  });
                },
              ),
              Text((checkBoxVal) ? germanDateTime(value["checked"]) : ""),
            ]),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (checkBoxVal)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                            ConstrainedBox(
                              constraints: new BoxConstraints(
                                minHeight: 35.0,
                                //maxHeight: 60.0,
                              ),
                              child: SelectableText(
                                textController[key]!.text,
                              ),
                            ),
                            deleteButton,
                          ])
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
                                      textController[key]!.text;
                                  createNewToDo(key.toString(), widget.afzIdx!);
                                } else {
                                  WebComunicater.sendRequest(<String, String>{
                                    'auth':
                                        Preferences.prefs!.getString("key")!,
                                    'toDoNewText': textController[key]!.text,
                                    'toDoIdx': value['idx'].toString(),
                                  });
                                }
                                setState(() {
                                  final snackBar = SnackBar(
                                    content: Row(children: [
                                      Text('Gespeichert'),
                                      Icon(Icons.save_outlined,
                                          color: Colors.green)
                                    ]),
                                    //padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                                    margin: EdgeInsets.fromLTRB(20, 0, 20, 30),
                                    duration: Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                    //animation: new Animation(),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                        side: BorderSide(color: Colors.grey)),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                  HapticFeedback.heavyImpact();
                                  widget.toDoMap!.updateAll((mapIdx, value) {
                                    if (mapIdx == key) {
                                      value["text"] = textController[key]!.text;
                                    }
                                    return value;
                                  });
                                  //savedText[key] = textController[key].text;
                                });
                              }),
                          InkWell(
                            child: Icon(Icons.cancel_outlined,
                                size: 40, color: Colors.red),
                            onTap: () {
                              HapticFeedback.heavyImpact();
                              setState(() {});
                            },
                          ),
                          deleteButton,
                          Text("erstellt:\n" +
                              germanDateTime(value["created"].toString())),
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
