import 'package:Bombelczyk/helperClasses/Tour.dart';
import 'package:Bombelczyk/widgets/Calendar.dart';
import 'package:Bombelczyk/widgets/Clickables.dart';
import 'package:Bombelczyk/widgets/Tour.dart';
import 'package:material_ui/material_ui.dart';

class Tours extends StatefulWidget {
  Tours({Key? key}) : super(key: key);

  @override
  ToursState createState() => ToursState();
}

class ToursState extends State<Tours> {
  DateTime selectedDay = DateTime.now();
  final Map<Tour, void Function(Tour)> _deleteListeners = {};

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      this.selectedDay = selectedDay;
    });
  }

  Future<void> onRefresh() async {
    await ToursHandler.instance.refetch();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (final entry in _deleteListeners.entries) {
      entry.key.removeDeleteListener(entry.value);
    }
    _deleteListeners.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Tour> tours = ToursHandler.instance.eventLoader(selectedDay, setState);

    tours.forEach((element) {
      if (!_deleteListeners.containsKey(element)) {
        void onTourDeleted(Tour _) {
          if (mounted) {
            setState(() {});
          }
        }

        element.addDeleteListener(onTourDeleted);
        _deleteListeners[element] = onTourDeleted;
      }
    });
    return RefreshIndicator(
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
                setState,
              ),
            ),
            Column(
              children: tours.map((e) => TourWidget(e, setState)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
