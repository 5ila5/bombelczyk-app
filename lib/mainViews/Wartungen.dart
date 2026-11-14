import 'package:Bombelczyk/helperClasses/Aufzug.dart';
import 'package:Bombelczyk/helperClasses/WebComunicator.dart';
import 'package:Bombelczyk/helperClasses/geoLocation.dart';
import 'package:Bombelczyk/widgets/AufzugBar.dart';
import 'package:Bombelczyk/widgets/DropDownMenu.dart';
import 'package:Bombelczyk/widgets/MyFutureBuilder.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';

class Wartungen extends StatefulWidget {
  @override
  _WartungenState createState() => _WartungenState();
}

class _WartungenState extends State<Wartungen> {
  Future<List<AufzugWithMonth>> afzs;
  bool sortedByDistance = true;

  _WartungenState()
    : afzs = WebComunicater.instance.getWartungen(
        Geolocation.determinePositionOrNull(),
      );

  Future<void> refresh() async {
    setState(() {
      afzs = WebComunicater.instance.getWartungen(
        Geolocation.determinePositionOrNull(),
      );
    });
  }

  List<AufzugWithMonth> _sorted_afzs(List<AufzugWithMonth> afzs) => afzs.sorted(
    (a, b) => sortedByDistance
        ? a.distance.compareTo(b.distance)
        : a.year.compareTo(b.year) != 0
        ? a.year.compareTo(b.year)
        : a.month.compareTo(b.month) != 0
        ? a.month.compareTo(b.month)
        : a.afzIdx.compareTo(b.afzIdx),
  );

  List<Widget> _buildWidgets(List<AufzugWithMonth> afzs) {
    List<Widget> toReturn = [
      CheckboxListTile(
        title: Text("Sortieren nach Entfernung"),
        value: sortedByDistance,
        onChanged: (value) {
          setState(() {
            sortedByDistance = value ?? true;
          });
        },
      ),
    ];
    (int, int) lastYearMonth = (-1, -1);
    int cnt = 0;
    _sorted_afzs(afzs).forEach((e) {
      if (lastYearMonth != (e.year, e.month)) {
        lastYearMonth = (e.year, e.month);
        toReturn.add(
          Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Text(
              "${e.year} - ${e.month}",
              style: TextStyle(fontSize: 20),
            ),
          ),
        );
      }

      toReturn.add(
        SimpleAufzugBarWithDistanceAndTourButton(
          e,
          context,
          odd: cnt++ & 1 == 1,
        ),
      );
    });
    return toReturn;
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
            Center(
              child: WidgetColumnFutureBuilder(
                afzs.then((value) => _buildWidgets(value)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
