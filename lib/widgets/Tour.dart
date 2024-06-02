import 'package:Bombelczyk/helperClasses/Aufzug.dart';
import 'package:Bombelczyk/helperClasses/Tour.dart';
import 'package:Bombelczyk/mainViews/TourEdit.dart';
import 'package:Bombelczyk/widgets/AufzugBar.dart';
import 'package:collapsible/collapsible.dart';
import 'package:flutter/material.dart';

class TourWidgetHelper {
  static void showAddToTourDialog(BuildContext context, Aufzug aufzug) {
    // TODO: implement
    print("Showing dialog for adding Aufzug ${aufzug.anr} to tour");
  }

  static void showCreateDialog(BuildContext context, DateTime date,
      void Function(void Function()) updateParent) {
    TourEdit.showPage(context, Tour.dateOnly(date), updateParent);
  }

  static void editTour(BuildContext context, Tour tour,
      void Function(void Function()) updateParent) {
    TourEdit.showPage(context, tour, updateParent);
  }

  static void confimDeleteTour(BuildContext context, Tour tour,
      final void Function(void Function()) updateParent) {
    _deleteConfirmDialog(BuildContext context) {
      // set up the buttons
      Widget remindButton = TextButton(
        child: Text("Ja"),
        onPressed: () {
          updateParent(() => tour.delete());

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
  }
}

class TourHeader extends StatelessWidget {
  final Tour tour;
  final bool collapsed;
  final void Function()? onTap;
  final void Function(void Function()) updateParent;

  Widget buttons(Tour tour, BuildContext context) {
    return Row(children: [
      InkWell(
          onTap: () => TourWidgetHelper.editTour(context, tour, updateParent),
          child: Icon(Icons.edit, color: Colors.green, size: 30)),
      InkWell(
          onTap: () =>
              TourWidgetHelper.confimDeleteTour(context, tour, updateParent),
          child: Icon(Icons.delete, color: Colors.red, size: 30)),
    ]);
  }

  TourHeader(this.onTap, this.collapsed, this.tour, this.updateParent);

  @override
  Widget build(BuildContext context) => Container(
      margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
      child: Material(
          elevation: 20,
          child: Container(
            color: Colors.blue,
            padding: EdgeInsets.only(bottom: 5, top: 5),
            child: Row(children: [
              Expanded(
                  child: InkWell(
                onTap: onTap,
                child: Row(
                  children: [
                    Icon(
                        (collapsed)
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: Colors.white),
                    Text(
                      tour.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )),
              Container(
                margin: EdgeInsets.only(right: 20),
                child: buttons(
                  tour,
                  context,
                ),
              ),
            ]),
          )));
}

class TourWidget extends StatefulWidget {
  final Tour tour;
  final bool edit_mode;

  TourWidget(this.tour, {this.edit_mode = false});

  @override
  _TourWidgetState createState() => _TourWidgetState();
}

class _TourWidgetState extends State<TourWidget> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    print("Building TourWidget: " + widget.tour.aufzuege.toString());
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Row(
          children: [
            Expanded(
              child: TourHeader(
                  () => setState(() {
                        _collapsed = !_collapsed;
                      }),
                  _collapsed,
                  widget.tour,
                  setState),
            )
          ],
        ),
        Collapsible(
            child: ListView(
              shrinkWrap: true,
              children: widget.tour.aufzuege
                  .map((e) => widget.edit_mode
                      ? TourModifiableAufzugBar(e, setState,
                          odd: widget.tour.aufzuege.indexOf(e) & 1 == 1,
                          finished: e.finished)
                      : TourAufzugBarWithState(e,
                          odd: widget.tour.aufzuege.indexOf(e) & 1 == 1,
                          finished: e.finished))
                  .toList(),
            ),
            collapsed: _collapsed,
            axis: CollapsibleAxis.both),
      ],
    );
  }
}
