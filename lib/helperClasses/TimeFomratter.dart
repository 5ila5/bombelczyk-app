import 'package:intl/intl.dart';

class TimeFormatter {
  static final DateFormat germanTimeFormat = DateFormat('dd.MM.yy HH:mm');

  static String germanTimeString(DateTime time) {
    return germanTimeFormat.format(time);
  }
}
