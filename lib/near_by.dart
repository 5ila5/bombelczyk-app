import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'web_comunicater.dart';
import 'auto_key.dart';
import 'dart:convert';
import 'helper.dart';

class NearBy extends StatefulWidget {
  NearBy({
    Key key,
  }) : super(key: key);

  @override
  NearByState createState() => NearByState();
}

class NearByState extends State<NearBy> {
  List<Widget> _neaByWidgets = [Text("")];
  int _menge = 10;

  @override
  void initState() {
    super.initState();
    getNearby();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: getNearby,
        child: Center(
            child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: _neaByWidgets,
          ),
        )));
  }

  Future<void> getNearby() async {
    bool error = false;
    String errorMessage;

    if (_neaByWidgets.length < 2) {
      createDropDown(true);
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
      'anz': _menge.toString(),
      //'auth':"12345678910",
      //"sort": _sort.toString(),
      //"sortDirection": _sortDirection.toString(),
    });
    if (response == "notLoggedIn") {
      AuthKey.wrongKey(context);
      return;
    }

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

    List<Widget> tmpWidgets = [createDropDown(true)];
    String entfernungsText = "";
    bool even = true;
    Color /*!*/ tablecolor = Colors.grey[300];

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
                      launchUrlString(
                          "https://www.google.de/maps/search/?api=1&query=" +
                              value["Astr"].toString() +
                              "+" +
                              value["Ahnr"].toString() +
                              ",+" +
                              value["plz"].toString() +
                              "+" +
                              value["Ort"].toString(),
                          mode: LaunchMode.externalNonBrowserApplication);
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

  Widget createDropDown(bool working) {
    if (working) {
      _neaByWidgets.add(CircularProgressIndicator());
    }
    //print("create Drop down");
    //print(_neaByWidgets.length);
    if (_neaByWidgets.length == 1) {
      setState(() {
        _neaByWidgets
            .addAll([createDropDown(true), CircularProgressIndicator()]);
      });
    }

    return Row(children: [
      Text("Menge: "),
      DropdownButton<int>(
        value: _menge,
        onChanged: (int newValue) {
          if (newValue == null) return;
          _menge = newValue;
          //print("set State");
          if (working) {
            //print("working");
            setState(() {
              _neaByWidgets[0] = createDropDown(true);
              //print("working...");
            });
          } else {
            //print("not working");
            setState(() {
              _neaByWidgets[0] = createDropDown(true);
            });
          }
          getNearby();
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
}
