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
  List<Tour> _listeningOn = [];
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      this.selectedDay = selectedDay;
    });
  }

  Future<void> onRefresh() async {
    await ToursHandler.instance.refetch();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Tour> tours = ToursHandler.instance.eventLoader(selectedDay, setState);

    tours.forEach((element) {
      if (!_listeningOn.contains(element)) {
        element.addDeleteListener((t) => setState(() {}));
        _listeningOn.add(element);
      }
    });
    return RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(children: [
              TourCalendar(onDaySelected),
              AddTour(
                  onPressed: () => TourWidgetHelper.showCreateDialog(
                      context, selectedDay, setState)),
              Column(
                  children: tours.map((e) => TourWidget(e, setState)).toList())
            ])));
  }
}
