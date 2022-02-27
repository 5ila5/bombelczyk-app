import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'events.dart';
import 'package:intl/intl.dart';
import 'web_comunicater.dart';

class AddEventForm extends StatefulWidget {
  DateTime defaultDate;
  EventList eventList = EventList.getInstance();
  AddEventForm({
    Key key,
    this.defaultDate,
    this.eventList,
  }) : super(key: key);

  @override
  AddEventFormState createState() => AddEventFormState();
}

class AddEventFormState extends State<AddEventForm> {
  DateTime _selectedDay = DateTime.now();
  final DateFormat formatter = DateFormat('dd.MM.yyyy', 'de_DE');
  final DateFormat sendFormatter = DateFormat('yyyy-MM-dd');

  TextEditingController titleController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.defaultDate != null) this._selectedDay = widget.defaultDate;
  }

  List<Event> _getEvent(DateTime day) {
    //print(day.toString());
    List<Event> toReturn = [];
    widget.eventList.forEach((Event element) {
      if (isSameDay(element.date, day)) {
        toReturn.add(element);
      }
    });
    return toReturn;
  }

  bool isInt(String s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null;
  }

  void _addEvent() {
    print("hash in add");
    print(widget.eventList.hashCode);
    String text = titleController.value.text;
    Future<String> response = WebComunicater.sendRequest(
        {"tour_text": text, "tour_date": sendFormatter.format(_selectedDay)});
    response.then((String responseStr) {
      log(responseStr);
      if (isInt(responseStr)) {
        widget.eventList
            .add(Event(int.parse(responseStr), _selectedDay, text, []));
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Row(
            children: [
              Text("Datum:"),
              InkWell(
                child: Column(children: [
                  Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.blue, style: BorderStyle.solid),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Row(children: [
                        Text(
                          formatter.format(_selectedDay),
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.blue,
                        )
                      ]))
                ]),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                            child: SingleChildScrollView(
                                physics: AlwaysScrollableScrollPhysics(),
                                child: Container(
                                    child: Column(children: [
                                  StatefulBuilder(
                                      builder: (context, StateSetter setState) {
                                    return TableCalendar(
                                      availableGestures:
                                          AvailableGestures.horizontalSwipe,
                                      firstDay: DateTime.now(),
                                      lastDay: DateTime.now()
                                          .add(Duration(days: 356 * 4)),
                                      focusedDay: _selectedDay,
                                      calendarFormat: CalendarFormat.month,
                                      availableCalendarFormats: {
                                        CalendarFormat.month: "monat"
                                      },
                                      onDaySelected: (selected, focused) {
                                        setState(() {
                                          _selectedDay = selected;
                                        });
                                      },
                                      selectedDayPredicate: (day) {
                                        return isSameDay(_selectedDay, day);
                                      },
                                      weekendDays: [
                                        DateTime.saturday,
                                        DateTime.sunday
                                      ],
                                      locale: 'de_DE',
                                      eventLoader: _getEvent,
                                      startingDayOfWeek:
                                          StartingDayOfWeek.monday,
                                    );
                                  }),
                                  FloatingActionButton(
                                    onPressed: () {
                                      setState(() {
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Text("OK"),
                                  ),
                                ]))));
                      });
                },
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Text("Titel"),
                Expanded(
                    child: Container(
                        padding: EdgeInsets.only(left: 20, right: 5),
                        child: TextField(
                          autocorrect: true,
                          controller: titleController,
                          style: TextStyle(
                            color: Colors.black,
                            //backgroundColor: ,
                          ),
                          strutStyle: StrutStyle(
                            fontSize: 20,
                          ),
                          decoration: InputDecoration(
                            fillColor: Colors.grey[600],
                          ),
                          maxLength: 100,
                        )))
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                  flex: 1,
                  child: FloatingActionButton(
                    onPressed: _addEvent,
                    child: Text("OK"),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    backgroundColor: Colors.green,
                  )),
              Expanded(
                  flex: 2,
                  child: Container(
                      padding: EdgeInsets.only(left: 10),
                      child: FloatingActionButton(
                        backgroundColor: Colors.red,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Abbrechen"),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                      )))
            ],
          )
        ],
      ),
    );
  }
}
