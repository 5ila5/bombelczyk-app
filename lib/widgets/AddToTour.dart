import 'package:Bombelczyk/helperClasses/Aufzug.dart';
import 'package:Bombelczyk/helperClasses/Tour.dart';
import 'package:Bombelczyk/widgets/Calendar.dart';
import 'package:Bombelczyk/widgets/Clickables.dart';
import 'package:Bombelczyk/widgets/Tour.dart';
import 'package:material_ui/material_ui.dart';

class AddAfzToTour extends StatefulWidget {
  final Aufzug afz;
  AddAfzToTour(this.afz, {Key? key}) : super(key: key);

  static void showPage(BuildContext context, Aufzug afz) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddAfzToTour(afz)),
    );
  }

  @override
  AddAfzToTourState createState() => AddAfzToTourState();
}

class AddAfzToTourState extends State<AddAfzToTour> {
  DateTime selectedDay = DateTime.now();
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      this.selectedDay = selectedDay;
    });
  }

  Future<void> onRefresh() async {
    await ToursHandler.instance.refetch();
    setState(() {});
  }

  void updateParentDummy(void Function()) {}

  @override
  Widget build(BuildContext context) {
    List<Tour> tours = ToursHandler.instance.eventLoader(selectedDay, setState);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Flexible(
              child: Container(
                //padding: EdgeInsets.only(right: 5),
                child: Text(
                  "${widget.afz.anr} - Zu Tour hinzufügen",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              TourCalendar(onDaySelected),
              AddTour(
                onPressed: () => TourWidgetHelper.showCreateDialog(
                  context,
                  selectedDay,
                  updateParentDummy,
                  preselectedAufzuege: [widget.afz],
                  replaceView: true,
                ),
              ),
              Column(
                children: tours
                    .map(
                      (e) => TextButton(
                        onPressed: () {
                          TourWidgetHelper.editTour(
                            context,
                            e,
                            updateParentDummy,
                            preselectedAufzuege: [widget.afz],
                            replaceView: true,
                          );
                          // Exit the dialog after adding the tour
                          // Navigator.of(context).pop();
                        },
                        child: Text("${e.name}"),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
