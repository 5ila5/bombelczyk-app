import 'package:Bombelczyk/helperClasses/SortTypes.dart';
import 'package:Bombelczyk/helperClasses/WebComunicator.dart';
import 'package:Bombelczyk/widgets/AufzugBar.dart';
import 'package:Bombelczyk/widgets/DropDownMenu.dart';
import 'package:Bombelczyk/widgets/MyFutureBuilder.dart';
import 'package:Bombelczyk/widgets/TextFields.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Future<List<Widget>> contentList = Future.value([]);
  Sort currentSort = Sort(AfzSortType.STREET, SortDirection.ASC);
  String search = "";

  void updateContent() {
    setState(() {
      contentList = WebComunicater.instance
          .searchAufzug(search, currentSort)
          .then((value) => value.map((afz) => SimpleAufzugBar(afz)).toList());
    });
  }

  void searchChange([String? newSearch]) {
    search = newSearch ?? search;
    if ((newSearch ?? search).length < 3) {
      setState(() {
        contentList =
            Future.value([Text("Geben Sie mindestens 3 Zeichen ein")]);
      });
    }
    updateContent();
  }

  void sortChange(Sort? newSort) {
    if (newSort == null) return;
    currentSort = newSort;
    searchChange();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AfzSearchBar("Suche Aufzüge", searchChange),
      SortDropDownWithDir(currentSort, sortChange),
      WidgetColumnFutureBuilder(contentList)
    ]);
  }
}
