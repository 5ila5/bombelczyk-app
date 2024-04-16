import 'package:Bombelczyk/helperClasses/Tour.dart';
import 'package:Bombelczyk/widgets/Tour.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';



class MyCalendar<T> extends StatefulWidget {
  final void Function(DateTime, DateTime)? onDaySelected;
  final CalendarFormat defaultFormat;
  final DateTime defaultDate; 
  final List<T> Function(DateTime)? eventLoader;
  final List<T> Function(DateTime, void Function(void Function() ))? eventLoaderWithSetState;

  MyCalendar(this.onDaySelected, {this.eventLoader, this.eventLoaderWithSetState, DateTime? defaultDate, this.defaultFormat = CalendarFormat.week}) : defaultDate = defaultDate ?? DateTime.now();


  @override
  _MyCalendarState<T> createState() => _MyCalendarState<T>(defaultFormat, defaultDate);

}

class _MyCalendarState<T> extends State<MyCalendar<T>> {
  CalendarFormat _calendarFormat;
  DateTime _selectedDay;


  _MyCalendarState(this._calendarFormat, this._selectedDay);

@override
  Widget build(BuildContext context) {
    return TableCalendar<T>(
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
      firstDay: DateTime.utc(2021),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (DateTime oldDay, DateTime newDay) {
        setState(() {
          _selectedDay = _selectedDay;
          if (widget.onDaySelected != null) {
            widget.onDaySelected!(oldDay, newDay);
          }
        });
      },
      startingDayOfWeek: StartingDayOfWeek.monday,
      eventLoader: widget.eventLoader ?? (day) { if ( widget.eventLoaderWithSetState != null) return widget.eventLoaderWithSetState!(day, setState); return [];},
    );
  }

}



class TourCalendar extends MyCalendar<Tour> {
  TourCalendar(void Function(DateTime, DateTime)? onDaySelected) : super(
    onDaySelected,
    eventLoaderWithSetState: (day, setState) => ToursHandler.instance.eventLoader(day, setState),
    defaultDate: DateTime.now(),
    defaultFormat: CalendarFormat.week
  );
  
}
