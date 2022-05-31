import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'helper.dart';
import 'events.dart';

import 'package:url_launcher/url_launcher_string.dart';

//ignore: must_be_immutable
class AufzugListItem extends StatefulWidget {
  Color tablecolor;
  String anr;
  String astr;
  String ahnr;
  String plz;
  String ort;
  String fKZeit;
  String zgTxt;
  String afzIdx;
  bool showMapIcon;
  Function customOnclick;

  AufzugListItem({
    Key key,
    this.anr,
    this.astr,
    this.ahnr,
    this.plz,
    this.ort = "",
    this.fKZeit = "",
    this.zgTxt,
    this.afzIdx,
    this.tablecolor,
    Aufzug aufzug,
    this.showMapIcon = true,
    this.customOnclick,
  }) {
    if (fKZeit == null) {
      fKZeit = "NULL";
    }
    if (aufzug != null) {
      this.anr = aufzug.getAnr();
      this.astr = aufzug.getAstr();
      this.ahnr = aufzug.getAhnr();
      this.plz = aufzug.getplz().toString();
      this.ort = aufzug.getOrt();
      this.fKZeit = aufzug.getFK_zeit();
      this.zgTxt = aufzug.getZg_txt();
      this.afzIdx = aufzug.getAfzIdx().toString();
    }
  }

  @override
  AufzugListItemState createState() => AufzugListItemState();
}

class AufzugListItemState extends State<AufzugListItem> {
  @override
  Widget build(BuildContext context) {
    TextStyle tableRowTopStyle =
        TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey[900]);
    TextStyle tableRowBottomStyle = TextStyle(
      fontWeight: FontWeight.normal,
    );
    List<Widget> columnChildren = [
      Row(children: [
        Flexible(
            child: Text(
          widget.anr + "  " + widget.astr + " " + widget.ahnr,
          style: tableRowTopStyle,
          overflow: TextOverflow.fade,
        )),
      ]),
      Row(
        children: [
          //Text(widget.plz + " ", style: tableRowBottomStyle,overflow: TextOverflow.fade,),
          Flexible(
            child: Text(
              widget.plz + " " + widget.ort,
              style: tableRowBottomStyle,
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
      Row(
        children: [
          Flexible(
            child: Text(
              "Anfahrt " + widget.fKZeit,
              style: tableRowBottomStyle,
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
      //Divider(),
    ];
    if (widget.zgTxt.length > 2) {
      columnChildren.add(Row(
        children: [
          Flexible(
            child: Text(
              "Schlüssel " + widget.zgTxt,
              style: tableRowBottomStyle,
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ));
    }

    return Container(
      padding:
          const EdgeInsets.only(right: 20.0, left: 10.0, bottom: 5.0, top: 5.0),
      //padding: const EdgeInsets.only(left: 10.0),
      color: widget.tablecolor,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: new InkWell(
                  child: Column(
                    children: columnChildren,
                  ),
                  onTap: () {
                    print("widget.customOnclick");
                    print(widget.customOnclick);

                    if (widget.customOnclick == null) {
                      print("selectElevator");
                      SelectElevator.selectElevator(
                          widget.afzIdx,
                          widget.anr,
                          widget.astr + " " + widget.ahnr,
                          widget.plz,
                          widget.ort,
                          widget.fKZeit,
                          widget.zgTxt,
                          context);
                    } else {
                      print("customOnclick(Aufzug.fromArgs");
                      widget.customOnclick(Aufzug.fromArgs(
                          int.parse(widget.afzIdx),
                          widget.anr,
                          widget.astr,
                          widget.ahnr,
                          int.parse(widget.plz),
                          widget.ort,
                          widget.fKZeit,
                          widget.zgTxt));
                    }
                  },
                ),
              ),
              if (widget.showMapIcon)
                new InkWell(
                  child: Icon(
                    Icons.map_outlined,
                    size: 50,
                    color: Colors.blue,
                  ),
                  onTap: () {
                    launchUrlString(
                        "https://www.google.de/maps/search/?api=1&query=" +
                            widget.astr +
                            "+" +
                            widget.ahnr +
                            ",+" +
                            widget.plz +
                            "+" +
                            widget.ort);
                  },
                ),
            ],
          ),
          //Divider(thickness: 0.0),
        ],
      ),
    );
  }
}
