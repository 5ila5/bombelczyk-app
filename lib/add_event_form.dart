import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'events.dart';
import 'package:intl/intl.dart';
import 'web_comunicater.dart';
import 'suche.dart';
import 'tour_single.dart';
import 'multiselect.dart';
import 'tour_get_general.dart';

class AddEventForm extends StatefulWidget {
  final DateTime defaultDate;
  final EventList eventList;
  final int id;
  final Event event;
  final bool createNew;

  AddEventForm({
    Key key,
    this.defaultDate,
    this.id = -1,
  })  : this.event = Event(id, DateTime.now(), "", []),
        this.createNew = true,
        this.eventList = EventList.getInstance(),
        super(key: key);

  AddEventForm.fromEvent(this.event)
      : this.defaultDate = event.date,
        this.id = event.id,
        eventList = EventList.getInstance(),
        this.createNew = false;

  @override
  AddEventFormState createState() => AddEventFormState();
}

class AddEventFormState extends State<AddEventForm> {
  TourGeneralInfo tourInfos = TourGeneralInfo.getInstance();
  DateTime _selectedDay = DateTime.now();
  final DateFormat formatter = DateFormat('dd.MM.yyyy', 'de_DE');
  final DateFormat sendFormatter = DateFormat('yyyy-MM-dd');
  List<int> shareWith = [];

  //List<Aufzug> aufzuege = [];

  TextEditingController titleController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.defaultDate != null) this._selectedDay = widget.defaultDate;

    titleController.text = widget.event.text;
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

  void showShare() async {
    this.shareWith = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(items: tourInfos.personen, selected: shareWith);
      },
    );
    print(shareWith);
  }

  void _addEvent() {
    String text = titleController.value.text;
    Map<String, String> requestContent = {
      "tour_text": text,
      "tour_date": sendFormatter.format(_selectedDay),
      "aufzuege": widget.event.getAfzIdxList().toString(),
      "aufzuege_arbeit": widget.event.getAfzArbeit().toString(),
      if (widget.id != -1) "tour_id": widget.id.toString(),
      if (this.shareWith.length != 0) "share_width": this.shareWith.toString(),
    };

    Future<String> response = WebComunicater.sendRequest(requestContent);
    log((this.shareWith != []).toString());
    log(this.shareWith.toString());
    log("request:");
    log(requestContent.toString());
    response.then((String responseStr) {
      log(responseStr);
      if (isInt(responseStr)) {
        widget.event.id = int.parse(responseStr);
        widget.event.date = _selectedDay;
        if (widget.createNew) {
          widget.eventList.add(widget
              .event); //Event(int.parse(responseStr), _selectedDay, text, []));
        }
        widget.eventList.save();
        Navigator.pop(context);
      }
    });
  }

  Widget workDropDown(int afzIdx) {
    Aufzug afz = widget.event.getAfzWithIdx(afzIdx);
    if (afz == null) {
      return Text("error");
    }

    return DropdownButton<String>(
      elevation: 1,
      borderRadius: BorderRadius.all(Radius.circular(3)),
      icon: Icon(Icons.arrow_downward),
      items: tourInfos
          .getArbeitsArtStringList()
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String newVal) => {
        setState(() {
          print("changed Dropdown to:" + newVal);
          afz.setArbeit(newVal);
        })
      },
      value: afz.getArbeit(),
    );
  }

  @override
  Widget build(BuildContext context) {
    /*List<Widget> afzList = [];
    this.aufzuege.forEach((Aufzug afz) => {
      afzList.add(Text(afz.toJson()))
    });
    */

    Tour tour = Tour(
      () => setState(() {}),
      event: this.widget.event,
      editMode: true,
      customWorkWidget: workDropDown,
    );
    widget.event.text = titleController.text;

    return Center(
      child: SingleChildScrollView(
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
                                    StatefulBuilder(builder:
                                        (context, StateSetter setState) {
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
                            onChanged: (String t) => setState(() {}),
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
            Row(children: [
              InkWell(
                child: Container(
                    child: Row(
                      children: [Text("Teilen"), Icon(Icons.share, size: 30)],
                    ),
                    color: Colors.green),
                onTap: showShare,
              )
            ]),

            //Tour(()=>setState(() {print("refreshParent");}),event:Event(widget.id,DateTime.now(), titleController.text, this.aufzuege) ),
            tour,
            Container(
              width: 800,
              height: 400,
              child: Suche(
                  showMapIcon: false,
                  customOnclick: (Aufzug afz) => {
                        setState(() {
                          this.widget.event.addAfz(afz);

                          List<String> arbeiten =
                              tourInfos.getArbeitsArtStringList();
                          if (arbeiten.length > 0) {
                            afz.setArbeit(arbeiten[0]);
                          }
                          afz.setErledigt(false);
                        })
                      }),
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
      ),
    );
  }
}
