class Arbeit {
  final int _id;
  final int _arbBeNr;
  final String _date;
  final List<String> _workers;
  final String _work;
  final String _description;

  Arbeit(this._id, this._arbBeNr, this._date, this._workers, this._work,
      this._description);

  Arbeit.fromApiJson(Map<String, dynamic> json)
      : _id = json["LfdNr"],
        _arbBeNr = json["ArbBeNr"],
        _date = json["ArbDat"],
        _workers = (json["MitarbeiterName"] as String).split(", "),
        _work = json["AusgfArbeit"],
        _description = json["Kurztext"];

  int get id => _id;
  int get arbBeNr => _arbBeNr;
  String get date => _date;

  List<String> get workers => _workers;
  String get work => _work;
  String get description => _description;
  String get workersString => _workers.join(", ");
}
