import 'package:Bombelczyk/helperClasses/StorageHelper.dart';
import 'package:Bombelczyk/helperClasses/WebComunicator.dart';
import 'package:Bombelczyk/mainViews/History.dart';
import 'package:Bombelczyk/mainViews/Nearby.dart';
import 'package:Bombelczyk/mainViews/Search.dart';
import 'package:Bombelczyk/mainViews/ToDo.dart';
import 'package:Bombelczyk/mainViews/TourEdit.dart';
import 'package:Bombelczyk/mainViews/Tours.dart';
import 'package:Bombelczyk/widgets/AufzugPage.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        AufzugPage.aufzugRoute: (context) => AufzugPage.fromContext(),
        TourEdit.TourEditRoute: (context) => TourEdit.fromContext(),
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
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  static List<Widget>? _widgetOptions;

  Map<String, dynamic>? toDoresponseMap;

  @override
  void initState() {
    super.initState();
    StorageHelper.initWebComunicator();
    WebComunicater.instance.testConnection().then((v) {
      if (!v) Login.displayLoginDialog(context);
    }).catchError((error, stackTrace) {
      if (error is WrongAuthException) Login.displayLoginDialog(context);
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (_widgetOptions == null || _widgetOptions!.length == 0) {
      _widgetOptions = <Widget>[
        Search(),
        Nearby(),
        //To Dos Home
        ToDoView(),

        Column(children: <Widget>[
          new Expanded(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            //padding:const EdgeInsets.fromLTRB(5, 0, 0, 3),
            child: SingleChildScrollView(
              //  child: Column(
              //children:
              child: History(), //_ToDotabelle,
              //)
            ),
          )),
        ]),
        Tours(),
      ];
    }
    //refreshTable("");

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: //Center(
          //child:
          _widgetOptions!.elementAt(_selectedIndex),
      //),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Suche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_pin),
            label: 'In der Nähe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_rounded), //color: Colors.red,),
            label: 'To-Do',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Historie',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tour_rounded),
            label: 'Touren',
          ),
        ],
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        //selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.blueGrey,
        unselectedLabelStyle: TextStyle(
          color: Colors.blueGrey,
          //backgroundColor: Colors.green,
        ),
        //fixedColor: Colors.red,

        selectedItemColor: Colors.blue,

        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
