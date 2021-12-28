import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'helper.dart';

import 'package:url_launcher/url_launcher.dart';
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

  AufzugListItem(
      {Key key,
      this.anr,
      this.astr,
      this.ahnr,
      this.plz,
      this.ort,
      this.fKZeit,
      this.zgTxt,
      this.afzIdx,
      this.tablecolor})
      : super(key: key);

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
        Text(
          widget.anr + " ",
          style: tableRowTopStyle,
        ),
        Text(widget.astr + " " + widget.ahnr, style: tableRowTopStyle),
      ]),
      Row(
        children: [
          Text(widget.plz + " ", style: tableRowBottomStyle),
          Text(widget.ort, style: tableRowBottomStyle),
        ],
      ),
      Row(
        children: [
          Text("Anfahrt ", style: tableRowBottomStyle),
          Text(widget.fKZeit, style: tableRowBottomStyle),
        ],
      ),
      //Divider(),
    ];
    if (widget.zgTxt.length > 2) {
      columnChildren.add(Row(
        children: [
          Text("Schlüssel ", style: tableRowBottomStyle),
          Text(widget.zgTxt, style: tableRowBottomStyle),
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
                    SelectElevator.selectElevator(
                        widget.afzIdx,
                        widget.anr,
                        widget.astr + " " + widget.ahnr,
                        widget.plz,
                        widget.ort,
                        widget.fKZeit,
                        widget.zgTxt,
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
                  launch("https://www.google.de/maps/search/?api=1&query=" +
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