import 'package:Bombelczyk/helperClasses/Tour.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class MyCalendar<T> extends StatefulWidget {
  final void Function(DateTime selectedDay, DateTime focusedDay)? onDaySelected;
  final CalendarFormat defaultFormat;
  final DateTime defaultDate;
  final List<T> Function(DateTime)? eventLoader;
  final List<T> Function(DateTime, void Function(void Function()))?
      eventLoaderWithSetState;

  MyCalendar(this.onDaySelected,
      {this.eventLoader,
      this.eventLoaderWithSetState,
      DateTime? defaultDate,
      this.defaultFormat = CalendarFormat.week})
      : defaultDate = defaultDate ?? DateTime.now();

  @override
  _MyCalendarState<T> createState() =>
      _MyCalendarState<T>(defaultFormat, defaultDate);
}

class _MyCalendarState<T> extends State<MyCalendar<T>> {
  CalendarFormat _calendarFormat;
  DateTime _selectedDay;
  DateTime _focusedDay;

  _MyCalendarState(this._calendarFormat, this._selectedDay)
      : _focusedDay = _selectedDay;

  @override
  Widget build(BuildContext context) {
    return TableCalendar<T>(
      calendarBuilders: CalendarBuilders(
        headerTitleBuilder: (c, d) =>
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(DateFormat.yMMMM("de_DE").format(d)),
          IconButton(
            icon: Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ]),
        //headerTitleBuilder: headerBuilder,
      ),
      weekNumbersVisible: true,
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
      onPageChanged: (focusedDay) => _focusedDay = focusedDay,
      weekendDays: [DateTime.saturday, DateTime.sunday],
      locale: 'de_DE',
      calendarFormat: _calendarFormat,
      focusedDay: _focusedDay,
      firstDay: DateTime.utc(2021),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          if (widget.onDaySelected != null) {
            widget.onDaySelected!(selectedDay, focusedDay);
          }
        });
      },
      startingDayOfWeek: StartingDayOfWeek.monday,
      eventLoader: widget.eventLoader ??
          (day) {
            if (widget.eventLoaderWithSetState != null)
              return widget.eventLoaderWithSetState!(day, setState);
            return [];
          },
    );
  }
}

class TourCalendar extends MyCalendar<Tour> {
  TourCalendar(void Function(DateTime, DateTime)? onDaySelected)
      : super(onDaySelected,
            eventLoaderWithSetState: (day, setState) =>
                ToursHandler.instance.eventLoader(day, setState),
            defaultDate: DateTime.now(),
            defaultFormat: CalendarFormat.week);
}
