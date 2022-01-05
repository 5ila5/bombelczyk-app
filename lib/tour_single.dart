import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collapsible/collapsible.dart';
import 'events.dart';

class Tour extends StatefulWidget {
  Event event;
  bool collapsed = false;
  Map<String, dynamic> afzToAdd;

  Tour({
    Key key,
    this.collapsed,
    this.event,
    addable = false,
    this.afzToAdd,
  }) : super(key: key);

  @override
  TourState createState() => TourState();
}

class TourState extends State<Tour> {
  bool _collapsed;

  @override
  void initState() {
    print("init");
    super.initState();
    _collapsed = widget.collapsed;
  }

  @override
  Widget build(BuildContext context) {
    print("build");

    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: Container(
                    margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    child: Material(
                        elevation: 20,
                        child: Container(
                          color: Colors.blue,
                          padding: EdgeInsets.only(bottom: 5, top: 5),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _collapsed = !_collapsed;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                    (_collapsed)
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: Colors.white),
                                Text(
                                  widget.event.text,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))))
          ],
        ),
        Collapsible(
            child: Column(
              children: widget.event.getAfzWidgets(),
            ),
            collapsed: _collapsed,
            axis: CollapsibleAxis.both),
      ],
    );
  }
}
