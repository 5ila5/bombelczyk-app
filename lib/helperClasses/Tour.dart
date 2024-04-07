import 'package:Bombelczyk/editable/Editable.dart';
import 'package:Bombelczyk/helperClasses/Aufzug.dart';
import 'package:Bombelczyk/helperClasses/SortTypes.dart';
import 'package:Bombelczyk/helperClasses/TourWorkType.dart';
import 'package:Bombelczyk/helperClasses/User.dart';
import 'package:Bombelczyk/helperClasses/WebComunicator.dart';
import 'package:collection/collection.dart';

class Tour extends Editable<Tour, TourChange> with Deletable {
  List<TourAufzug> _aufzuege = [];
  final int _idx;
  final String _name;
  final DateTime _date;
  List<User> _sharedWith = [];

  Tour(this._idx, this._name, this._date, {List<TourAufzug>? aufzuege}) {
    if (aufzuege != null) {
      _aufzuege = aufzuege;
    }
  }

  Tour.fromApiJson(Map<String, dynamic> json, List<TourWorkType> workTypes)
      : _idx = json['idx'],
        _name = json['name'],
        _date = DateTime.parse(json['date']) {
    this._aufzuege = List<TourAufzug>.from(json['afzs']
        .map((e) => TourAufzug.fromApiJson(this, e, workTypes))
        .toList());
  }

  int get idx => returnIfNotDeleted(_idx);
  String get name => returnIfNotDeleted(changeOr("name", _name));
  DateTime get date => returnIfNotDeleted(changeOr("date", _date));
  List<TourAufzug> get aufzuege =>
      returnIfNotDeleted(changeOr("aufzuege_", aufzuege));
  List<User> get sharedWith =>
      returnIfNotDeleted(changeOr("sharedWith", _sharedWith));

  void set name(String name) {
    edit(TourChange("name", this._name, name));
  }

  void set date(DateTime date) {
    edit(TourChange("date", this._date, date));
  }

  void set aufzuege(List<TourAufzug> aufzuege) {
    edit(TourChange("aufzuege", this._aufzuege, aufzuege));
  }

  void addAufzug(TourAufzug aufzug) {
    TourChange<dynamic>? afzChange =
        this.changes.firstWhereOrNull((element) => element.attr == "aufzuege");
    if (afzChange != null) {
      afzChange.newValue.add(aufzug);
    } else {
      edit(TourChange("aufzuege", this._aufzuege, [..._aufzuege, aufzug]));
    }
  }

  void moveAfz(TourAufzug afz, MoveDirection dir, {bool immediate = false}) {
    int idx = this._aufzuege.indexOf(afz);
    if (idx == -1) {
      throw Exception("Aufzug not in tour");
    }
    List<TourAufzug> afzList = _aufzuege;

    if (!immediate) {
      afzList = [..._aufzuege];
      TourChange<dynamic>? afzChange = this
          .changes
          .firstWhereOrNull((element) => element.attr == "aufzuege");
      if (afzChange != null) {
        afzList = afzChange.newValue;
      }
    }

    if (dir == MoveDirection.UP) {
      if (idx == 0) {
        return;
      }
      afzList.removeAt(idx);
      afzList.insert(idx - 1, afz);
    } else {
      if (idx == afzList.length - 1) {
        return;
      }
      afzList.removeAt(idx);
      afzList.insert(idx + 1, afz);
    }
  }

  void removeAufzug(TourAufzug aufzug) {
    TourChange<dynamic>? afzChange =
        this.changes.firstWhereOrNull((element) => element.attr == "aufzuege");
    if (afzChange != null) {
      afzChange.newValue.remove(aufzug);
    } else {
      edit(TourChange(
          "aufzuege", this._aufzuege, [..._aufzuege]..remove(aufzug)));
    }
  }

  void set sharedWith(List<User> sharedWith) {
    edit(TourChange("sharedWith", this._sharedWith, sharedWith));
  }

  @override
  Tour get original =>
      Tour(this._idx, this._name, this._date, aufzuege: this._aufzuege);

  void shareWith(User user) {
    TourChange<dynamic>? shareChange =
        this.changes.firstWhereOrNull((element) => element.attr == "aufzuege");
    if (shareChange != null) {
      shareChange.newValue.add(user);
    } else {
      edit(TourChange("sharedWith", this._aufzuege, [..._sharedWith, user]));
    }
  }

  @override
  Future<Tour> create() {
    Future<Tour> newTour = WebComunicater.instance.createTourByTour(this);
    isDeleted = true;
    return newTour;
  }

  @override
  void delete() {
    WebComunicater.instance.deleteTour(this);
    super.delete();
  }

  @override
  Tour save() {
    if (this.changes.every((element) => !element.isChanged)) {
      return this;
    }

    Map<String, dynamic> changes = {};

    for (TourChange change in this.changes) {
      if (change.isChanged) {
        changes[change.attr] = change.newValue;
      }
    }

    WebComunicater.instance.modifyTour(this,
        name: changes["name"],
        date: changes["date"],
        share: changes["sharedWith"],
        afzs: changes["aufzuege"]);

    this.isDeleted = true;

    return Tour(
        this.idx, changes["name"] ?? this.name, changes["date"] ?? this.date,
        aufzuege: changes["aufzuege"] ?? this.aufzuege);
  }
}
