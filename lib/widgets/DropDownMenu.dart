import 'dart:async';

import 'package:Bombelczyk/helperClasses/SortTypes.dart';
import 'package:Bombelczyk/helperClasses/TimeFomratter.dart';
import 'package:Bombelczyk/helperClasses/TourWorkType.dart';
import 'package:Bombelczyk/widgets/Calendar.dart';
import 'package:Bombelczyk/widgets/Clickables.dart';
import 'package:Bombelczyk/widgets/MyFutureBuilder.dart';
import 'package:flutter/material.dart';

class SimpleAmountChooser extends StatefulWidget {
  final void Function(int?) onAmountChanged;
  final int defaultAmount;
  final List<int> amounts;

  SimpleAmountChooser(this.amounts, this.onAmountChanged, {int? defaultAmount})
      : defaultAmount = defaultAmount ?? amounts[0];

  @override
  SimpleAmountChooserState createState() =>
      SimpleAmountChooserState(defaultAmount);
}

class SimpleAmountChooserState extends State<SimpleAmountChooser> {
  int value;

  SimpleAmountChooserState(this.value);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text("Menge: "),
      DropdownButton<int>(
        value: value,
        onChanged: (value) => setState(() {
          if (value == null) return;
          this.value = value;
          widget.onAmountChanged(value);
        }),
        items: widget.amounts.map<DropdownMenuItem<int>>((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(value.toString()),
          );
        }).toList(),
      )
    ]);
  }
}

class SortDropDown extends DropdownButton<SortType> {
  SortDropDown(SortType startVal, void Function(SortType?) onChanged)
      : super(
          value: startVal,
          items:
              startVal.vals.map<DropdownMenuItem<SortType>>((SortType value) {
            return DropdownMenuItem<SortType>(
              value: value,
              child: Text(value.name),
            );
          }).toList(),
          onChanged: onChanged,
        );
}

class SortDropDownWithDir extends Row {
  static List<Widget> getChildren(Sort sort, void Function(Sort?) onChanged) {
    return [
      SortDropDown(
          sort.type, (c) => onChanged(Sort(c ?? sort.type, sort.direction))),
      InkWell(
        child: (sort.direction == SortDirection.ASC)
            ? Icon(Icons.arrow_downward)
            : Icon(Icons.arrow_upward),
        onTap: () {
          onChanged(Sort(
              sort.type,
              (sort.direction == SortDirection.ASC)
                  ? SortDirection.DESC
                  : SortDirection.ASC));
        },
      )
    ];
  }

  SortDropDownWithDir(Sort sort, void Function(Sort?) onChanged)
      : super(
          children: getChildren(sort, onChanged),
        );
}

class SortDropDownWithDirCollapsed extends Row {
  SortDropDownWithDirCollapsed(Sort sort, void Function(Sort?) onChanged,
      bool collapsed, void Function(bool) setCollapsed)
      : super(children: [
          ExpandAll(collapsed, (e) => setCollapsed(e)),
          ...SortDropDownWithDir.getChildren(sort, onChanged)
        ]);
}

class ArbeitDropDown extends DropdownButton<TourWorkType> {
  ArbeitDropDown(List<TourWorkType> items, TourWorkType startVal,
      void Function(TourWorkType?) onChanged)
      : super(
          value: startVal,
          items:
              items.map<DropdownMenuItem<TourWorkType>>((TourWorkType value) {
            return DropdownMenuItem<TourWorkType>(
              value: value,
              child: Text(value.name),
            );
          }).toList(),
          onChanged: onChanged,
        );
}

class ArbeitDropDownFutureBuilder extends FutureBuilder<List<TourWorkType>> {
  ArbeitDropDownFutureBuilder(
      TourWorkType startVal, void Function(TourWorkType?) onChanged)
      : super(
            future: TourWorkTypes.getTypes(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ArbeitDropDown(snapshot.data!, startVal, onChanged);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              } else {
                return CircularProgressIndicator();
              }
            });
}

class DatePicker extends StatefulWidget {
  final DateTime defaultDate;
  final void Function(DateTime) onDateChanged;
  DatePicker(this.defaultDate, this.onDateChanged);

  @override
  DatePickerState createState() => DatePickerState(defaultDate);
}

class DatePickerState extends State<DatePicker> {
  DateTime _selectedDay;

  DatePickerState(this._selectedDay);

  Widget dialogueBuilder(BuildContext context) {
    return Dialog(
        child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Container(
                child: Column(children: [
              StatefulBuilder(builder: (context, StateSetter setState) {
                return MyCalendar((selectedDate, focusedDate) {
                  widget.onDateChanged(selectedDate);
                  setState(() {
                    _selectedDay = selectedDate;
                  });
                }, defaultDate: _selectedDay);
              }),
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    Navigator.pop(context, _selectedDay);
                  });
                },
                child: Text("OK"),
              ),
            ]))));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Column(children: [
        Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, style: BorderStyle.solid),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Row(children: [
              Text(
                TimeFormatter.germanDateString(_selectedDay),
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
        Future<DateTime?> newDate = showDialog(
          context: context,
          builder: dialogueBuilder,
        );
        newDate.then((value) {
          if (value != null) {
            widget.onDateChanged(value);
          }
        });
      },
    );
  }
}

class MultiSelect<T> extends StatefulWidget {
  final List<T>? items;
  final List<T> selected;
  final FutureOr<String> Function(T) nameGetter;
  MultiSelect(
      {FutureOr<String> Function(T)? nameGetter,
      Key? key,
      this.items,
      List<T> selected = const []})
      : nameGetter = nameGetter ?? ((T t) => t.toString()),
        this.selected = [...selected],
        super(key: key);

  @override
  _MultiSelectState<T> createState() => _MultiSelectState<T>();
}

class _MultiSelectState<T> extends State<MultiSelect<T>> {
  // this variable holds the selected items
  List<T> selected = [];
  @override
  initState() {
    super.initState();
    this.selected = widget.selected;
  }

// This function is triggered when a checkbox is checked or unchecked
  void _itemChange(T item, bool? isSelected) {
    setState(() {
      if (isSelected != null && isSelected) {
        selected.add(item);
      } else {
        selected.remove(item);
      }
    });
  }

  // this function is called when the Cancel button is pressed
  void _cancel() {
    Navigator.pop(context);
  }

// this function is called when the Submit button is tapped
  void _submit() {
    Navigator.pop(context, selected);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> itemWidgets = [
      Text(
          "Personen mit denen die Tour schon geteilt wurde werden hier trotzdem nicht als ausgewählt angezeigt")
    ];
    widget.items!.forEach((item) {
      Widget titleWideget;
      FutureOr<String> name = widget.nameGetter(item);
      if (name is String) {
        titleWideget = Text(name);
      } else {
        titleWideget =
            CircularProgressIndicatorFutureBuilder(name, (n) => Text(n));
      }
      itemWidgets.add(CheckboxListTile(
        value: selected.contains(item),
        title: titleWideget,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (isChecked) => _itemChange(item, isChecked),
        dense: true,
        isThreeLine: false,
      ));
    });
    return AlertDialog(
      title: const Text('Teilen mit'),
      content: SingleChildScrollView(
        child: ListBody(
          children: itemWidgets,
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: _cancel,
        ),
        ElevatedButton(
          child: const Text('Submit'),
          onPressed: _submit,
        ),
      ],
    );
  }
}
