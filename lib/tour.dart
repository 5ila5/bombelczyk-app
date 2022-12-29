import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'tour_get_general.dart';
import 'tour_single.dart';
import 'package:intl/intl.dart';
import 'events.dart';
import 'add_event_form.dart';

class Tours extends StatefulWidget {
  Tours({
    Key? key,
  }) : super(key: key);

  @override
  ToursState createState() => ToursState();
}

class ToursState<T extends Tours> extends State<T> {
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('MMMM yyyy', 'de_DE');
  TourGeneralInfo tourInfos = TourGeneralInfo.getInstance();
  bool allowPastSelect = true;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  EventList _eventList = EventList.getInstance();
  List<Widget> _tours = [];

  @protected
  void setSelectedDay(DateTime s) {
    _selectedDay = s;
  }

  @protected
  void setFocusedDay(DateTime s) {
    _focusedDay = s;
  }

  @protected
  void setTours(List<Widget> tours) {
    this._tours = tours;
  }

  @protected
  EventList getEventList() {
    return _eventList;
  }

  void refresh() async {
    //log("refresh From child");
    //checkPrefs();
    await _eventList.load();
    //checkPrefs();
    //log("refresh from child: _eventList:" + _eventList.toJson());
    //setState(() {});
    _onDaySelected(_selectedDay, _focusedDay);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!allowPastSelect &&
        (selectedDay.isBefore(now) && !isSameDay(selectedDay, now))) {
      return;
    }

    //print("select");
    //print(_tours.toString());
    bool _first = true;
    _selectedDay = selectedDay;
    _focusedDay = focusedDay;
    _tours = [];
    _eventList.forEach((Event element) {
      if (isSameDay(element.date, selectedDay)) {
        // update `_focusedDay` here as well
        _tours.add(loadTour(element, _first));
        //print(_tours.toString());
        _first = false;
      }
    });
    setState(() {});
  }

  Widget loadTour(Event e, bool first) {
    return Tour(refresh,
        event: e,
        collapsed: !first,
        edit: () => {print("edit Pressed"), addEvent(event: e)});
  }

  void checkPrefs() async {
    /* log("prefEvents");
    log((await Preferences.getPrefs()).getString('events'));
    log("Events:");  */
  }

  Future<void> getEvents({bool respectCashe = false}) async {
    checkPrefs();
    if (respectCashe == false || _eventList.lastWebCall().inMinutes > 5) {
      getWebEvents();
    }
    await _eventList.load();

    initEvents();

    setState(() {});
  }

  void initEvents() {
    DateTime now = DateTime.now();
    Duration closest = Duration(days: 50);
    Duration difference;

    _eventList.forEach((Event element) {
      difference = element.date.difference(now);
      if (difference.inHours > 0 && difference.compareTo(closest) < 0) {
        closest = difference;
        _selectedDay = element.date;
      }
    });
    setState(() {
      _onDaySelected(_selectedDay, _focusedDay);
    });
  }

  Future<void> getWebEvents() async {
    print("in Get From WEB");
    await _eventList.loadFromWeb();
  }

  @override
  void initState() {
    super.initState();
    getEvents(respectCashe: true);
  }

  void addEvent({Event? event}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              child: Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Colors.white,
            ),
            child: (event == null)
                ? AddEventForm(defaultDate: _selectedDay)
                : AddEventForm.fromEvent(event),
          ));
        }).then((value) {
      setState(() {
        _onDaySelected(_selectedDay, _focusedDay);
      });
    });
  }

  List<Event> _getEvent(DateTime day) {
    //print(day.toString());
    List<Event> toReturn = [];
    _eventList.forEach((Event element) {
      if (isSameDay(element.date, day)) {
        toReturn.add(element);
      }
    });
    return toReturn;
  }

  /*Widget headerBuilder(BuildContext context, DateTime day) {
    //return Text("test");

    return Row(children: [
      Text(
        formatter.format(day),
        style: TextStyle(fontSize: 17),
      ),
      Container(
          margin: EdgeInsets.only(left: 5),
          child: InkWell(
            child: Icon(
              Icons.add_circle,
              color: Colors.blue,
              size: 35,
            ),
            onTap: addEvent,
          ))
    ]); //Text("test");
  }*/

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: getEvents,
        child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                /* FloatingActionButton.extended(
                    label: Text("refresh"),
                    onPressed: () {
                      setState(() {});
                    }),
                FloatingActionButton.extended(
                    label: Text("check Prefs"),
                    onPressed: () {
                      checkPrefs();
                    }), */
                Container(
                  margin: EdgeInsets.only(right: 5, top: 5),
                  alignment: Alignment.topRight,
                  height: 40,
                  child: FloatingActionButton.extended(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    onPressed: addEvent,
                    label: Text("Neue Tour Anlegen"),
                    icon: Icon(
                      Icons.add_circle,
                      color: Colors.black,

                      //size: 35,
                    ),
                  ),
                ),
                TableCalendar<Event>(
                  calendarBuilders: CalendarBuilders(
                      //headerTitleBuilder: test,
                      //headerTitleBuilder: headerBuilder,
                      ),
                  availableCalendarFormats: {
                    CalendarFormat.month: "L",
                    CalendarFormat.twoWeeks: "M",
                    CalendarFormat.week: "S"
                  },
                  availableGestures: AvailableGestures.horizontalSwipe,
                  headerStyle: HeaderStyle(),
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
                  firstDay: (allowPastSelect)
                      ? DateTime.utc(2021)
                      : DateTime(now.year, now.month, now.day),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: _onDaySelected,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  eventLoader: _getEvent,
                ),
                ListBody(
                  children: _tours,
                ),
              ],
            )));
  }
}
