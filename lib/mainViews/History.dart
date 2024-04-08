import 'package:Bombelczyk/helperClasses/WebComunicator.dart';
import 'package:Bombelczyk/widgets/AufzugBar.dart';
import 'package:Bombelczyk/widgets/MyFutureBuilder.dart';
import 'package:flutter/material.dart';

class HistoryState extends StatelessWidget {
  Future<List<Widget>> getAfzWidgets() {
    return WebComunicater.instance.getHistory().then((value) {
      return value.map((e) => SimpleAufzugBar(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<List<Widget>> widgets = getAfzWidgets();

    return Center(
        child:
            SingleChildScrollView(child: WidgetColumnFutureBuilder(widgets)));
  }
}
