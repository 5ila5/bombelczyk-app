import 'package:Bombelczyk/helperClasses/TimeFomratter.dart';

class Arbeit {
  final int _id;
  final int _arbBeNr;
  final DateTime _date;
  final List<String> _workers;
  final String _work;
  final String _description;

  Arbeit(this._id, this._arbBeNr, this._date, this._workers, this._work,
      this._description);

  Arbeit.fromApiJson(Map<String, dynamic> json)
      : _id = json["LfdNr"],
        _arbBeNr = json["arbBeNr"],
        _date = DateTime.parse(json["ArbDat"]),
        _workers = json["workers"].split(", "),
        _work = json["AusgfArbeit"],
        _description = json["Kurztext"];

  int get id => _id;
  int get arbBeNr => _arbBeNr;
  DateTime get date => _date;
  String get dateString => TimeFormatter.germanDateString(_date);

  List<String> get workers => _workers;
  String get work => _work;
  String get description => _description;
  String get workersString => _workers.join(", ");
}
