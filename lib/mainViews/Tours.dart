import 'package:Bombelczyk/helperClasses/Tour.dart';
import 'package:Bombelczyk/widgets/Calendar.dart';
import 'package:Bombelczyk/widgets/Clickables.dart';
import 'package:Bombelczyk/widgets/Tour.dart';
import 'package:flutter/material.dart';

class Tours extends StatefulWidget {
  Tours({
    Key? key,
  }) : super(key: key);

  @override
  ToursState createState() => ToursState();
}

class ToursState extends State<Tours> {
  DateTime selectedDay = DateTime.now();
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {}

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TourCalendar(onDaySelected),
      AddTour(
          onPressed: () =>
              TourWidgetHelper.showCreateDialog(context, selectedDay)),
      Column(
          children: ToursHandler.instance
              .eventLoader(selectedDay, setState)
              .map((e) => TourWidget(e))
              .toList())
    ]);
  }
}
