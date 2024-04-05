import 'package:flutter/material.dart';
import 'helper.dart';
import 'web_comunicater.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'auto_key.dart';
import 'to_do_home_list.dart';

class ToDoHome extends StatefulWidget {
  //Map <String,dynamic> toDoresponseMap;
  //String afzIdx;

  ToDoHome({Key? key}) : super(key: key);

  @override
  ToDoHomeState createState() => ToDoHomeState();
}

class ToDoHomeState extends State<ToDoHome> {
  bool _toDoSortDirection = false;
  int _toDoSort = 1;
  TextEditingController _searchToDoController = new TextEditingController();
  bool _toDoShowChecked = false;
  bool _toDoShowUnchecked = true;
  Future<Map<String, dynamic>>? toDoresponseMap;
  bool firstBuild = true;
  bool allExpanded = false;
  Map<String, Widget> expandedWidgets = {};

  refreshToDoTable(String text) async {
    setState(() {
      toDoresponseMap = searchToDos(text);
    });
  }

  Future<Map<String, dynamic>> searchToDos(String search) async {
    Map<String, dynamic> tmpResponseMap = {};

    String response = await WebComunicater.sendRequest(<String, String>{
      'toDoSearchText': search,
      "toDoSort": _toDoSort.toString(),
      "sortDirection": _toDoSortDirection.toString(),
      "showChecked": _toDoShowChecked.toString(),
      "showUnchecked": _toDoShowUnchecked.toString(),
    });
    if (response == "notLoggedIn") {
      AuthKey.wrongKey(context);
      return {};
    }
    /*print("showChecked: " +
        _toDoShowChecked.toString() +
        "\nshowUnchecked: " +
        _toDoShowUnchecked.toString());*/

    String responseStr = response.replaceAll("\n", "");
    //print("responseStr:");
    //print(response);
    if (responseStr == "false") {
      AuthKey.wrongKey(context);

      return {};
    }
    tmpResponseMap = Map<String, dynamic>.from(jsonDecode(responseStr));
    if (tmpResponseMap["error"]) {
      //_requestError = true;
      setState(() {});
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
          InkWell(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Transform.rotate(
                  child: Icon(Icons.double_arrow, color: Colors.blue),
                  angle: ((this.allExpanded) ? 90 : 270) * math.pi / 180,
                )),
            onTap: () {
              setState(() {
                this.allExpanded = !this.allExpanded;
              });
            },
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 20, 0),
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
                onChanged: (ToDoSorts? newValue) {
                  if (newValue == null) return;
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
          (MediaQuery.of(context).orientation == Orientation.portrait)
              ? Column(children: [
                  Row(
                    children: [
                      Icon(Icons.check),
                      Checkbox(
                        value: _toDoShowChecked,
                        onChanged: (bool? val) {
                          if (val != null && (val || _toDoShowUnchecked)) {
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
                        onChanged: (bool? val) {
                          if (val != null && (val || _toDoShowChecked)) {
                            _toDoShowUnchecked = !_toDoShowUnchecked;
                            refreshToDoTable(_searchToDoController.text);
                          }
                        },
                      )
                    ],
                  ),
                ])
              : Row(
                  children: [
                    Icon(Icons.check),
                    Checkbox(
                      value: _toDoShowChecked,
                      onChanged: (bool? val) {
                        if (val != null && (val || _toDoShowUnchecked)) {
                          _toDoShowChecked = !_toDoShowChecked;
                          refreshToDoTable(_searchToDoController.text);
                        }
                      },
                    ),
                    Padding(padding: const EdgeInsets.fromLTRB(10, 0, 10, 0)),
                    Icon(Icons.crop_square_sharp),
                    Checkbox(
                      value: _toDoShowUnchecked,
                      onChanged: (bool? val) {
                        if (val != null && (val || _toDoShowChecked)) {
                          _toDoShowUnchecked = !_toDoShowUnchecked;
                          refreshToDoTable(_searchToDoController.text);
                        }
                      },
                    ),
                  ],
                ),
        ]), //),
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
                    allExpanded: this.allExpanded,
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
