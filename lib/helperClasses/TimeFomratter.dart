import 'package:intl/intl.dart';

class TimeFormatter {
  static final DateFormat germanTimeFormat = DateFormat('dd.MM.yy HH:mm');
  static final DateFormat germanDateFormat = DateFormat('dd.MM.yy');

  static String germanTimeString(DateTime time) {
    return germanTimeFormat.format(time);
  }

  static String germanDateString(DateTime time) {
    return germanDateFormat.format(time);
  }
}
