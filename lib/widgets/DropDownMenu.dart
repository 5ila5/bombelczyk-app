import 'package:Bombelczyk/helperClasses/SortTypes.dart';
import 'package:Bombelczyk/widgets/Inkwells.dart';
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
