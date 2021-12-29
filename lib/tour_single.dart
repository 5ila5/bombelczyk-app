import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collapsible/collapsible.dart';
import 'helper.dart';

class Tour extends StatefulWidget {
  Event event;
  bool collapsed = false;

  Tour({
    Key key,
    this.collapsed,
    this.event,
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
                          color: Colors.grey,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _collapsed = !_collapsed;
                              });
                            },
                            child: Row(
                              children: [
                                Icon((_collapsed) ?Icons.keyboard_arrow_up_rounded: Icons.keyboard_arrow_down_rounded),
                                Text(
                                  widget.event.text,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                    color: Colors.blueGrey[900],
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
