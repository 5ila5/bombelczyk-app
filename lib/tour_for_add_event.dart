import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'events.dart';
import 'tour.dart';
import 'tour_single.dart';

class TourForAddToEvent extends Tours {
  final Map<String, dynamic> afz;

  TourForAddToEvent(
    this.afz, {
    Key? key,
  }) : super();

  @override
  TourForAddToEventState createState() => TourForAddToEventState();
}

class TourForAddToEventState extends ToursState<TourForAddToEvent> {
  @override
  void initState() {
    super.initState();
    allowPastSelect = false;
  }

  @override
  Widget loadTour(Event e, bool first) {
    //bool containsAfz = false;
    //List<Widget> _widgets = [];

    return Tour(
      refresh,
      collapsed: !first,
      event: e,
      addable: true,
      afzToAdd: Aufzug(widget.afz),
    );
    /*e.afz.forEach((Aufzug a) {
      containsAfz = a.hasIdx(widget.afz["afzIdx"]);
      _widgets.add(Container(
          height: 80,
          width: 280,
          //child: Expanded(
          child: InkWell(
              child: Row(children: [
            //Checkbox(value: containsAfz, onChanged: (val) => print(val)),
            //Expanded(
            //height: 20,
            //width: 50,
            Expanded(
                child: Tour(
              collapsed: !first,
              event: e,
            )),
          ]))));
      first = false;
    });
    return Container(
        //height: 200,
        //width: 200,
        child: Column(
      children: _widgets,
    ));*/
  }
}
