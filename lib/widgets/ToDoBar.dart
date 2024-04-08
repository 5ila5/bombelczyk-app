import 'package:Bombelczyk/helperClasses/SavedVisualizer.dart';
import 'package:Bombelczyk/helperClasses/TimeFomratter.dart';
import 'package:Bombelczyk/helperClasses/ToDo.dart';
import 'package:Bombelczyk/widgets/Inkwells.dart';
import 'package:Bombelczyk/widgets/MyFutureBuilder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ToDoBar extends StatefulWidget {
  final ToDo todo;
  final void Function() informDelete;

  ToDoBar(this.todo, this.informDelete);

  @override
  _ToDoBarState createState() => _ToDoBarState(todo);
}

class _ToDoBarState extends State<ToDoBar> {
  ToDo todo;

  _ToDoBarState(this.todo);

  void _save() {
    todo = todo.save();
  }

  DeleteInkWell _getDeleteButton() => DeleteInkWell(() {
        todo.delete();
        HapticFeedback.heavyImpact();
        widget.informDelete();
      });

  Row getBottomRow() {
    return Row(children: [
      SaveInkWell(() {
        setState(() {
          todo = todo.save();
          _save();
          SavedVisualizer.showSavedVisualizer(context);
          //savedText[key] = textController[key].text;
        });
      }, todo.hasChanged),
      CancelInkWell(() {
        setState(() {
          todo.cancel();
          HapticFeedback.heavyImpact();
        });
      }, todo.hasChanged),
      _getDeleteButton(),
      Text("erstellt:\n" + TimeFormatter.germanTimeString(todo.creationDate)),
    ]);
  }

  Widget _getCheckedText() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: new BoxConstraints(
                minHeight: 35.0,
                //maxHeight: 60.0,
              ),
              child: SelectableText(
                todo.text,
              ),
            ),
            _getDeleteButton(),
          ]);

  Widget _getUncheckedText() => Column(children: [
        TextField(
          onChanged: (String t) => todo.text = t,
          controller: TextEditingController(text: todo.text),
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: const InputDecoration(),
        ),
        getBottomRow(),
      ]);

  @override
  Widget build(BuildContext context) {
    return Table(columnWidths: {
      0: FlexColumnWidth(1.19),
      1: FlexColumnWidth(6),
    }, children: [
      TableRow(children: [
        Column(children: [
          Checkbox(
            value: (todo.isDone),
            onChanged: (bool? newValue) {
              setState(() {
                todo.isDone = newValue!;
              });
            },
          ),
          Text((todo.isDone)
              ? TimeFormatter.germanTimeString(todo.doneDate!)
              : ""),
        ]),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (todo.isDone) ? _getCheckedText() : _getUncheckedText(),
          ],
        ),
      ]),
    ]);
  }
}

class UncreatedToDoBar extends ToDoBar {
  final void Function(Future<ToDo>) onCreated;
  UncreatedToDoBar(ToDo todo, void Function() informDelete, this.onCreated)
      : super(todo, informDelete);

  @override
  _UncreatedToDoBarState createState() =>
      _UncreatedToDoBarState(todo, onCreated);
}

class _UncreatedToDoBarState extends _ToDoBarState {
  final void Function(Future<ToDo>) onCreated;

  _UncreatedToDoBarState(ToDo todo, this.onCreated) : super(todo);

  @override
  void _save() {
    onCreated(todo.create());
  }
}

class NewToDoBar extends StatefulWidget {
  final ToDo todo;
  final void Function() informDelete;
  NewToDoBar(this.todo, this.informDelete);

  @override
  _NewToDoBarState createState() => _NewToDoBarState();
}

class _NewToDoBarState extends State<NewToDoBar> {
  Future<ToDo>? futureTodo;

  @override
  Widget build(BuildContext context) {
    if (futureTodo == null) {
      return UncreatedToDoBar(widget.todo, widget.informDelete, (p0) {
        setState(() {
          futureTodo = p0;
        });
      });
    }
    return CircularProgressIndicatorFutureBuilder(
        futureTodo!, (p0) => ToDoBar(p0, widget.informDelete));
  }
}
