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
  String arbeit;
  Function customWorkWidget;
  bool erledigt;
  Function check;

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
    this.arbeit,
    this.customWorkWidget,
    this.erledigt,
    this.check,
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
    TextStyle tableRowTopStyle = TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey[900],
        fontSize: DefaultTextStyle.of(context).style.fontSize);

    TextStyle tableRowBottomStyle = TextStyle(
      fontWeight: FontWeight.normal,
    );
    List<Widget> columnChildren = [
      if (widget.customWorkWidget != null)
        Row(children: [
          Flexible(child: widget.customWorkWidget(int.parse(widget.afzIdx))),
        ]),
      if (widget.customWorkWidget == null && widget.arbeit != null)
        Row(children: [
          Flexible(
              child: Text(
            widget.arbeit,
            style: tableRowTopStyle.apply(fontSizeFactor: 1.5),
            overflow: TextOverflow.fade,
          )),
        ]),
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
              Column(
                children: [
                  if (widget.customWorkWidget == null &&
                      widget.arbeit != null &&
                      widget.erledigt != null)
                    InkWell(
                      child: Icon(
                        Icons.check_circle,
                        color: (widget.erledigt) ? Colors.grey : Colors.green,
                        size: 50,
                      ),
                      onTap: () => widget.check(!widget.erledigt),
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
              )
            ],
          ),
          //Divider(thickness: 0.0),
        ],
      ),
    );
  }
}
