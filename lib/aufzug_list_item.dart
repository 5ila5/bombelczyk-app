import 'package:flutter/material.dart';
import 'helper.dart';
import 'events.dart';

import 'package:url_launcher/url_launcher_string.dart';

//ignore: must_be_immutable
class AufzugListItem extends StatefulWidget {
  Color tablecolor;
  final String anr;
  final String astr;
  final String ahnr;
  final String plz;
  final String ort;
  final String fKZeit;
  final String zgTxt;
  final String afzIdx;
  final bool showMapIcon;
  final Function customOnclick;
  final String arbeit;
  final Function customWorkWidget;
  final bool erledigt;
  final Function check;
  final String beschreibung;
  final int anzImg;
  final Function showImg;

  AufzugListItem(
      {Key key,
      this.anr = "-1",
      this.astr = "",
      this.ahnr = "",
      this.plz = "",
      this.ort = "",
      this.fKZeit = "NULL",
      this.zgTxt = "",
      this.afzIdx = "",
      this.tablecolor = Colors.white,
      //Aufzug aufzug,
      this.showMapIcon = true,
      this.customOnclick,
      this.arbeit = "",
      this.customWorkWidget,
      this.erledigt = false,
      this.check,
      this.beschreibung = "",
      this.anzImg = 0,
      this.showImg});

  AufzugListItem.fromAufzug(Aufzug aufzug,
      {Key key,
      this.showImg,
      this.showMapIcon = true,
      this.customOnclick,
      this.arbeit = "",
      this.customWorkWidget,
      this.erledigt = false,
      this.check,
      this.tablecolor = Colors.white})
      : this.anr = aufzug.getAnr(),
        this.astr = aufzug.getAstr(),
        this.ahnr = aufzug.getAhnr(),
        this.plz = aufzug.getplz().toString(),
        this.ort = aufzug.getOrt(),
        this.fKZeit = aufzug.getFkZeit(),
        this.zgTxt = aufzug.getZgTxt(),
        this.afzIdx = aufzug.getAfzIdx().toString(),
        this.beschreibung = aufzug.getBeschreibugn(),
        this.anzImg = aufzug.getAnzImg();

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

    if (widget.beschreibung != null && widget.beschreibung.length > 1) {
      columnChildren.add(Row(
        children: [
          Flexible(
            child: Text(
              "\n" + widget.beschreibung,
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
                  if (widget.anzImg != null && widget.anzImg > 0)
                    InkWell(
                      child: Row(
                        children: [
                          Text(widget.anzImg.toString(),
                              style: TextStyle(fontSize: 20)),
                          Icon(
                            Icons.image_outlined,
                            size: 50,
                          )
                        ],
                      ),
                      onTap: () =>
                          widget.showImg(context, int.parse(widget.afzIdx)),
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
                                widget.ort,
                            mode: LaunchMode.externalNonBrowserApplication);
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
