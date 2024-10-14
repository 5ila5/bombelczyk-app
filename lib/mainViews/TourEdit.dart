import 'package:Bombelczyk/helperClasses/Tour.dart';
import 'package:Bombelczyk/mainViews/Search.dart';
import 'package:Bombelczyk/widgets/Clickables.dart';
import 'package:Bombelczyk/widgets/DropDownMenu.dart';
import 'package:Bombelczyk/widgets/TextFields.dart';
import 'package:Bombelczyk/widgets/Tour.dart';
import 'package:flutter/material.dart';

class TourEdit extends StatelessWidget {
  final Tour? tour;

  static const TourEditRoute = '/TourEdit';

  static void showPage(BuildContext context, Tour tour,
      void Function(void Function()) updateParent) {
    Navigator.pushNamed(
      context,
      TourEdit.TourEditRoute,
      arguments: tour,
    ).then((value) {
      if (!tour.isDeleted) {
        tour.cancel();
      }
      updateParent(() {});
    });
  }

  TourEdit(Tour tour)
      : this.tour = tour,
        super();

  TourEdit.fromContext()
      : tour = null,
        super();

  @override
  Widget build(BuildContext context) {
    final Tour tour =
        this.tour ?? ModalRoute.of(context)!.settings.arguments as Tour;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Flexible(
            child: Container(
              //padding: EdgeInsets.only(right: 5),
              child: Text(
                tour.idx == -1
                    ? "Neue Tour"
                    : "Tour (" + tour.idx.toString() + ") Bearbeiten",
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ]),
      ),
      body: TourEditBody(tour),
    );
  }
}

class TourEditBody extends StatefulWidget {
  final Tour tour;
  TourEditBody(this.tour) : super();

  @override
  TourEditBodyState createState() => TourEditBodyState();
}

class TourEditBodyState extends State<TourEditBody> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        DatePicker(widget.tour.date, (d) => widget.tour.date = d),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 150),
          child: TourEditTitle(
              (s) => setState(
                    () {
                      widget.tour.name = s;
                    },
                  ),
              widget.tour.name),
        ),
        TourWidget(
          widget.tour,
          setState,
          edit_mode: true,
        ),
        ShareButton(widget.tour),
        ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height / 2),
            child: InkWell(
                child: Icon(
                  Icons.add,
                  size: 50,
                ),
                onTap: () => SearchPopup.show(context, onTap: (b) {
                      setState(() {
                        widget.tour.addAufzug(b);
                      });
                    }))),
        TourEditBottomButtons(widget.tour),
      ],
    );
  }
}
