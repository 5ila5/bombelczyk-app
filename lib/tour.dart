import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'web_comunicater.dart';
import 'auto_key.dart';
import 'dart:convert';
import 'tour_single.dart';
import 'helper.dart';

class Tours extends StatefulWidget {
  Tours({
    Key key,
  }) : super(key: key);

  @override
  ToursState createState() => ToursState();
}

class ToursState extends State<Tours> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  List<Event> _eventList = [];
  List<Tour> _tours = [];

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    print("select");
    print(_tours.toString());
    bool _first = true;

    _eventList.forEach((Event element) {
      if (element.date.difference(selectedDay).inHours.abs() < 12) {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        if (_first) _tours = []; // update `_focusedDay` here as well
        _tours.add(Tour(event: element, collapsed: !_first));
        print(_tours.toString());
        _first = false;


      }
    });
    setState(() {});
  }

  Future<void> get_events() async {
    String response = await WebComunicater.sendRequest({
      "get_events": "1",
    });
    if (response == null) {
      AuthKey.wrongKey(context);
      return;
    }
    response = response.replaceAll("\n", "");
    List<dynamic> tmp = List<dynamic>.from(jsonDecode(response));
    _eventList = [];
    DateTime now = DateTime.now();
    Duration closest = Duration(days: 50);
    Duration difference;
    tmp.forEach((element) {
      DateTime eventTime = DateTime.parse(element["Datum"]);
      difference = eventTime.difference(now);
      if (difference.inHours > 0 && difference.compareTo(closest) < 0) {
        closest = difference;
        _selectedDay = eventTime;
      }
      _eventList.add(
          Event(element["id"], eventTime, element["comment"], element["afz"]));
    });
    print(_eventList.toString());
    _onDaySelected(_selectedDay, _focusedDay);
  }

  @override
  void initState() {
    super.initState();
    get_events();
  }

  List<Event> _get_event(DateTime day) {
    //print(day.toString());
    List<Event> toReturn = [];
    _eventList.forEach((Event element) {
      if (element.date.difference(day).inHours.abs() < 12) {
        toReturn.add(element);
      }
    });
    return toReturn;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return RefreshIndicator(
        onRefresh: get_events,
          child:
    SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
      children: [
        TableCalendar<Event>(
          calendarStyle: CalendarStyle(
            outsideDaysVisible: true,
            weekendTextStyle: TextStyle(
              color: Colors.red,
            ),
          ),
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          weekendDays: [DateTime.saturday, DateTime.sunday],
          locale: 'de_DE',
          calendarFormat: _calendarFormat,
          focusedDay: _selectedDay,
          firstDay: DateTime.utc(2021),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: _onDaySelected,
          startingDayOfWeek: StartingDayOfWeek.monday,
          eventLoader: _get_event,
        ),
        ListBody(
          children: _tours,
        ),
      ],
    )));
  }
}
