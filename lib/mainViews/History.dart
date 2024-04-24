import 'package:Bombelczyk/helperClasses/WebComunicator.dart';
import 'package:Bombelczyk/widgets/AufzugBar.dart';
import 'package:Bombelczyk/widgets/MyFutureBuilder.dart';
import 'package:flutter/material.dart';

class History extends StatelessWidget {
  Future<List<Widget>> getAfzWidgets(BuildContext context) {
    return WebComunicater.instance.getHistory().then((value) {
      print("getAfzWidgets TESTS");
      print(value.map((e) => value.indexOf(e) & 1 == 1));
      return value
          .map((e) => SimpleAufzugBar(e, odd: value.indexOf(e) & 1 == 1))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<List<Widget>> widgets = getAfzWidgets(context);

    return Center(
        child:
            SingleChildScrollView(child: WidgetColumnFutureBuilder(widgets)));
  }
}
