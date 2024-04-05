import 'package:flutter/material.dart';

class Arbeiten extends StatelessWidget {
  final Map<String, dynamic> arbeitsMap;

  Arbeiten(this.arbeitsMap, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    this.arbeitsMap.forEach((key, value) {
      if (value["ArbDat"] == null) {
        value["ArbDat"] = "";
      }
      if (value["MitarbeiterName"] == null) {
        value["MitarbeiterName"] = "";
      }
      if (value["AusgfArbeit"] == null) {
        value["AusgfArbeit"] = "";
      }
      if (value["Kurztext"] == null) {
        value["Kurztext"] = "";
      }

      List<String> mitarbeiterList = value["MitarbeiterName"].split(",");
      //print(mitarbeiterList.toString());
      String mitarbeiter = "";
      //print(mitarbeiter);
      for (int i = 0; i < mitarbeiterList.length; i++) {
        if (i == 0)
          mitarbeiter += mitarbeiterList[i];
        else if (!mitarbeiter
            .replaceAll(" ", "")
            .contains(mitarbeiterList[i].replaceAll(" ", "")))
          mitarbeiter += "," + mitarbeiterList[i];
      }

      children.add(
        Table(
          children: [
            TableRow(children: [
              SelectableText("Datum"),
              SelectableText(value["ArbDat"]),
            ]),
            TableRow(children: [
              SelectableText("Monteur(e)"),
              SelectableText(mitarbeiter),
              //Text(value["MitarbeiterName"]),
            ]),
            TableRow(children: [
              SelectableText("Arbeit"),
              SelectableText(value["AusgfArbeit"]),
            ]),
            TableRow(children: [
              SelectableText("Kurztext"),
              SelectableText(value["Kurztext"]),
            ]),
          ],
        ),
      );
      children.add(Divider(thickness: 3, color: Colors.grey));
    });
    /*return Column(
       mainAxisAlignment: MainAxisAlignment.center,
       crossAxisAlignment: CrossAxisAlignment.center,

       //crossAxisCount: 6,
       children: children,
     );*/
    return ListView.builder(
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
      cacheExtent: children.length * 200.0,
    );
  }
}
