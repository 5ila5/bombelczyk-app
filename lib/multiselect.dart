import 'package:flutter/material.dart';

// Multi Select widget
// This widget is reusable
class MultiSelect extends StatefulWidget {
  final Map<int, String> items;
  List<int> selected = [];
  MultiSelect({Key key, this.items, this.selected}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  // this variable holds the selected items
  List<int> selected = [];

// This function is triggered when a checkbox is checked or unchecked
  void _itemChange(int idx, bool isSelected) {
    setState(() {
      if (isSelected) {
        selected.add(idx);
      } else {
        selected.remove(idx);
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
    widget.items.forEach((idx, name) => {
          itemWidgets.add(CheckboxListTile(
            value: selected.contains(idx),
            title: Text(name),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (isChecked) => _itemChange(idx, isChecked),
            //dense: true,
            isThreeLine: false,
          )),
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
