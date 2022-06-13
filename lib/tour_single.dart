import 'package:flutter/material.dart';
import 'package:collapsible/collapsible.dart';
import 'events.dart';
import "web_comunicater.dart";

class Tour extends StatefulWidget {
  final Event event;
  final bool collapsed;
  final Aufzug afzToAdd;
  final Function() refreshParent;
  final bool addable;
  final bool editMode;
  final Function edit;
  final Function customWorkWidget;
  Tour(this.refreshParent,
      {Key key,
      this.collapsed = false,
      this.event,
      this.addable = false,
      this.afzToAdd,
      this.editMode = false,
      this.edit,
      this.customWorkWidget})
      : super(key: key);

  @override
  TourState createState() => TourState();
}

class TourState extends State<Tour> {
  bool _collapsed;

  @override
  void initState() {
    // print("init");
    super.initState();
    _collapsed = widget.collapsed;
  }

  void delete() {
    EventList eventList = EventList.getInstance();
    WebComunicater.sendRequest(<String, String>{
      "DeleteTour": "true",
      "tourIdx": widget.event.id.toString(),
    }).then((r) => print("Tour Delete Response: " + r));

    eventList.events.remove(widget.event);
    eventList.save();
    widget.refreshParent();
  }

  _deleteConfirmDialog(BuildContext context) {
    // set up the buttons
    Widget remindButton = TextButton(
      child: Text("Ja"),
      onPressed: () {
        delete();
        Navigator.pop(context);
      },
    );
    Widget cancelButton = TextButton(
      child: Text("Abbrechen"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Notice"),
      content: Text("Bist du sicher, dass du diese Tour entfernen möchtest?"),
      actions: [
        remindButton,
        cancelButton,
      ],
    ); // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void addAfz() {
    EventList eventList = EventList.getInstance();
    widget.event.afz.add(widget.afzToAdd);
    eventList.save();
    WebComunicater.sendRequest(<String, String>{
      "addAfzToTour": "true",
      "tourIdx": widget.event.id.toString(),
      "afzIdx": widget.afzToAdd.getAfzIdx().toString(),
    }).then((value) => print(value));
    widget.refreshParent();
  }

  Widget buttons() {
    List<Widget> toReturn = [];

    if (widget.addable && !widget.event.containsAfz(widget.afzToAdd)) {
      widget.event.afz.forEach((Aufzug element) {
        // print(element.getAfzIdx().toString());
      });

      toReturn.add(
        InkWell(
            onTap: () => addAfz(),
            child: Icon(Icons.add, color: Colors.lightGreen, size: 30)),
      );
    }
    toReturn.add(
      InkWell(
          onTap: widget.edit,
          child: Icon(Icons.edit, color: Colors.green, size: 30)),
    );

    toReturn.add(
      InkWell(
          onTap: () => _deleteConfirmDialog(context),
          child: Icon(Icons.delete, color: Colors.red, size: 30)),
    );
    return Row(children: toReturn);
  }

  @override
  Widget build(BuildContext context) {
    // print("build");

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
                          child: Row(children: [
                            Expanded(
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
                            )),
                            if (!widget.editMode)
                              Container(
                                margin: EdgeInsets.only(right: 20),
                                child: buttons(),
                              ),
                          ]),
                        ))))
          ],
        ),
        Collapsible(
            child: Column(
              children: widget.event.getAfzWidgets(
                refresh: widget.refreshParent,
                toAdd: widget.afzToAdd,
                editMode: widget.editMode,
                customWorkWidget: widget.customWorkWidget,
              ),
            ),
            collapsed: _collapsed,
            axis: CollapsibleAxis.both),
      ],
    );
  }
}
