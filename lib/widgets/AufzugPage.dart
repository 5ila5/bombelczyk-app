import 'package:Bombelczyk/helperClasses/Aufzug.dart';
import 'package:Bombelczyk/helperClasses/StorageHelper.dart';
import 'package:Bombelczyk/helperClasses/WebComunicator.dart';
import 'package:Bombelczyk/widgets/Akku.dart';
import 'package:Bombelczyk/widgets/AufzugBar.dart';
import 'package:Bombelczyk/widgets/Clickables.dart';
import 'package:Bombelczyk/widgets/MyFutureBuilder.dart';
import 'package:Bombelczyk/widgets/Tour.dart';
import 'package:flutter/material.dart';

class AufzugPageHandler {
  static void showPage(BuildContext context, Aufzug aufzug) {
    StorageHelper.addHistory(aufzug);
    Navigator.pushNamed(
      context,
      AufzugPage.aufzugRoute,
      arguments: aufzug,
    );
  }
}

class MainAufzugTable extends DataTable {
  MainAufzugTable(Aufzug aufzug)
      : super(
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
              DataCell(SelectableText(aufzug.anr)),
            ]),
            DataRow(cells: [
              DataCell(SelectableText("Ort")),
              DataCell(SelectableText(aufzug.address.city)),
            ]),
            DataRow(cells: [
              DataCell(SelectableText("PLZ")),
              DataCell(SelectableText(aufzug.address.zipStr)),
            ]),
            DataRow(cells: [
              DataCell(SelectableText("Straße + Hausnummer")),
              DataCell(SelectableText(
                  aufzug.address.street + " " + aufzug.address.houseNumber)),
            ]),
            DataRow(cells: [
              DataCell(SelectableText("Anfahrtszeit")),
              DataCell(SelectableText(aufzug.fKZeit)),
            ]),
            DataRow(cells: [
              DataCell(SelectableText("Schlüsselort")),
              DataCell(SelectableText(aufzug.zgTxt)),
            ]),
          ],
        );
}

class ToDoWorkSelecter extends StatefulWidget {
  final Future<DetailedAufzug> aufzug;

  ToDoWorkSelecter(this.aufzug);

  @override
  _ToDoWorkSelecterState createState() => _ToDoWorkSelecterState();
}

class _ToDoWorkSelecterState extends State<ToDoWorkSelecter> {
  bool showToDo = false;

  _ToDoWorkSelecterState();

  void clickToDo() {
    setState(() {
      showToDo = true;
    });
  }

  void clickWork() {
    setState(() {
      showToDo = false;
    });
  }

  List<Widget> getWorkBars(DetailedAufzug afz) {
    return afz.arbeiten
        .map((work) =>
            [WorkBar(work), Divider(thickness: 1, color: Colors.grey)])
        .expand((e) => e)
        .toList();
  }

  List<Widget> getToDoBars(DetailedAufzug afz) {
    return ToDosBar.getToDoBars(afz, setState);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.aufzug,
        builder: (context, snapshot) {
          List<Widget> toReturn = [];
          if (snapshot.hasData) {
            toReturn = (showToDo)
                ? getToDoBars(snapshot.data!)
                : getWorkBars(snapshot.data!);
          } else if (snapshot.hasError) {
            if (snapshot.error is WrongAuthException) {
              Login.displayLoginDialog(context);
            }
            toReturn = [Text("${snapshot.error}")];
          } else {
            toReturn = [CircularProgressIndicator()];
          }
          print("build");
          return Column(children: [
            Table(children: [
              TableRow(children: [
                MyButton("To-Do", clickToDo, showToDo),
                MyButton("Arbeiten", clickWork, !showToDo),
              ])
            ]),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: toReturn.length,
              itemBuilder: (context, index) => toReturn[index],
              shrinkWrap: true,
              cacheExtent: toReturn.length * 200.0,
            )
          ]);
        });
  }
}

class AufzugPage extends StatelessWidget {
  final Aufzug? aufzug;
  static const aufzugRoute = '/aufzug_route';

  AufzugPage(Aufzug aufzug)
      : this.aufzug = aufzug,
        super();
  AufzugPage.fromContext()
      : aufzug = null,
        super();

  @override
  Widget build(BuildContext context) {
    final Aufzug aufzug =
        this.aufzug ?? ModalRoute.of(context)!.settings.arguments as Aufzug;
    Future<DetailedAufzug> detailedAufzug =
        WebComunicater.instance.getDetailedAufzug(aufzug);
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Flexible(
            child: Container(
              //padding: EdgeInsets.only(right: 5),
              child: Text(
                aufzug.anr + ", " + aufzug.address.street,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Container(
            child: InkWell(
              child: Icon(Icons.add_location_alt_sharp),
              onTap: () =>
                  TourWidgetHelper.showAddToTourDialog(context, aufzug),
            ),
          ),
        ]),
      ),
      body: Center(
        child: ListView(
          physics: ClampingScrollPhysics(),
          shrinkWrap: true,
          children: [
            MainAufzugTable(aufzug),
            Divider(),
            AkkuTableFutureBuilder(WebComunicater.instance.getAkkus(aufzug)),
            Divider(thickness: 3, color: Colors.black),
            ToDoWorkSelecter(detailedAufzug),
            Divider(thickness: 3, color: Colors.black)
          ],
        ),
      ),
    );
  }
}
