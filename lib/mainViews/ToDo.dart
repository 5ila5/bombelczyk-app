import 'package:Bombelczyk/helperClasses/SortTypes.dart';
import 'package:Bombelczyk/helperClasses/WebComunicator.dart';
import 'package:Bombelczyk/widgets/AufzugBar.dart';
import 'package:Bombelczyk/widgets/DropDownMenu.dart';
import 'package:Bombelczyk/widgets/MyFutureBuilder.dart';
import 'package:Bombelczyk/widgets/TextFields.dart';
import 'package:flutter/material.dart';

class ToDoView extends StatefulWidget {
  @override
  _ToDoViewState createState() => _ToDoViewState();
}

class _ToDoViewState extends State<ToDoView> {
  Future<List<Widget>> contentList = Future.value([]);
  Sort currentSort = Sort(ToDoSortType.STREET, SortDirection.ASC);
  bool show_checked = false;
  bool show_unchecked = true;
  String search = "";

  void updateContent() {
    setState(() {
      contentList = WebComunicater.instance
          .getToDos(
              search: search,
              show_checked: show_checked,
              show_unchecked: show_unchecked,
              sort: currentSort)
          .then((value) => value.map((afz) => ToDoAufzugBar(afz)).toList());
    });
  }

  void searchChange([String? newSearch]) {
    search = newSearch ?? search;
    if ((newSearch ?? search).length < 3) {
      setState(() {
        contentList =
            Future.value([Text("Geben Sie mindestens 3 Zeichen ein")]);
      });
      return;
    }
    updateContent();
  }

  void sortChange(Sort? newSort) {
    if (newSort == null) return;
    currentSort = newSort;
    searchChange();
  }

  void changeAllCollapsed(bool newCollapsed) {
    setState(() {
      contentList = WebComunicater.instance
          .getToDos(
              search: search,
              show_checked: show_checked,
              show_unchecked: show_unchecked,
              sort: currentSort)
          .then((value) =>
              value.map((afz) => ToDoAufzugBar(afz, newCollapsed)).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AfzSearchBar("Suche To-Dos", searchChange),
      SortDropDownWithDirCollapsed(
          currentSort, sortChange, true, changeAllCollapsed),
      WidgetColumnFutureBuilder(contentList)
    ]);
  }
}
