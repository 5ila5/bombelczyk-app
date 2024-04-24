import 'package:Bombelczyk/helperClasses/Aufzug.dart';
import 'package:Bombelczyk/helperClasses/SortTypes.dart';
import 'package:Bombelczyk/helperClasses/WebComunicator.dart';
import 'package:Bombelczyk/widgets/AufzugBar.dart';
import 'package:Bombelczyk/widgets/DropDownMenu.dart';
import 'package:Bombelczyk/widgets/MyFutureBuilder.dart';
import 'package:Bombelczyk/widgets/TextFields.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  final void Function(BuildContext)? customOnTap;

  Search({this.customOnTap}) : super();

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Future<List<Widget>> contentList = Future.value([]);
  Sort currentSort = Sort(AfzSortType.STREET, SortDirection.ASC);
  String search = "";

  SimpleAufzugBar getBar(Aufzug afz, bool odd) {
    if (widget.customOnTap != null) {
      return SimpleAufzugBar.withOnTap(afz, widget.customOnTap!, odd: odd);
    }
    return SimpleAufzugBar(afz, odd: odd);
  }

  void updateContent() {
    setState(() {
      contentList = WebComunicater.instance
          .searchAufzug(search, currentSort)
          .then((value) => value
              .map((afz) => this.getBar(afz, value.indexOf(afz) & 1 == 1))
              .toList());
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

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AfzSearchBar("Suche Aufzüge", (String s) => searchChange(s)),
      SortDropDownWithDir(currentSort, (Sort? s) => sortChange(s)),
      Expanded(child: WidgetScrollingColumnFutureBuilder(contentList))
    ]);
  }
}
