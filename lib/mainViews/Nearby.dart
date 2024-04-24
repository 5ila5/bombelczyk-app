import 'package:Bombelczyk/helperClasses/Aufzug.dart';
import 'package:Bombelczyk/helperClasses/WebComunicator.dart';
import 'package:Bombelczyk/helperClasses/geoLocation.dart';
import 'package:Bombelczyk/widgets/AufzugBar.dart';
import 'package:Bombelczyk/widgets/DropDownMenu.dart';
import 'package:Bombelczyk/widgets/MyFutureBuilder.dart';
import 'package:flutter/material.dart';

class Nearby extends StatefulWidget {
  @override
  _NearbyState createState() => _NearbyState();
}

class _NearbyState extends State<Nearby> {
  Future<List<AufzugWithDistance>> afzs;
  int _count;

  _NearbyState([count])
      : this._count = count ?? 10,
        afzs = WebComunicater.instance
            .getNearbyAufzug(Geolocation.determinePosition(), count ?? 10);

  Future<void> refresh() async {
    setState(() {
      afzs = WebComunicater.instance
          .getNearbyAufzug(Geolocation.determinePosition(), _count);
    });
  }

  void setCount(int? count) {
    if (count == null) return;
    if (count == _count) return;
    setState(() {
      _count = count;
      afzs = WebComunicater.instance
          .getNearbyAufzug(Geolocation.determinePosition(), count);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: refresh,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            // alignment top
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SimpleAmountChooser([10, 20, 50], setCount, defaultAmount: 10),
              Center(
                  child: WidgetColumnFutureBuilder(
                afzs.then((value) => value
                    .map((e) => SimpleAufzugBarWithDistance(e,
                        odd: value.indexOf(e) & 1 == 1))
                    .toList()),
              ))
            ],
          ),
        ));
  }
}
