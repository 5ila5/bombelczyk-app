import 'package:Bombelczyk/helperClasses/Tour.dart';
import 'package:Bombelczyk/mainViews/Search.dart';
import 'package:Bombelczyk/widgets/DropDownMenu.dart';
import 'package:Bombelczyk/widgets/TextFields.dart';
import 'package:Bombelczyk/widgets/Tour.dart';
import 'package:flutter/material.dart';

class TourEdit extends StatelessWidget {
  final Tour tour;
  static const aufzugRoute = '/aufzug_route';

  TourEdit(this.tour);

  @override
  Widget build(BuildContext context) {
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
      body: Center(
          child: SingleChildScrollView(
        child: TourEditBody(tour),
      )),
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
    return Row(
      children: [
        DatePicker(DateTime.now()),
        TourEditTitle((s) => setState(() {
              widget.tour.name = s;
            })),
        // Todo Share
        TourWidget(
          widget.tour,
          edit_mode: true,
        ),
        Search(
          customOnTap: (b) => setState(() => widget.tour.addAufzug),
        )
      ],
    );
  }
}
