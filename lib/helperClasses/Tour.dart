import 'dart:convert';

import 'package:Bombelczyk/editable/Editable.dart';
import 'package:Bombelczyk/helperClasses/Aufzug.dart';
import 'package:Bombelczyk/helperClasses/SortTypes.dart';
import 'package:Bombelczyk/helperClasses/TourWorkType.dart';
import 'package:Bombelczyk/helperClasses/User.dart';
import 'package:Bombelczyk/helperClasses/WebComunicator.dart';
import 'package:Bombelczyk/mainViews/Tours.dart';
import 'package:collection/collection.dart';

class Tour extends Editable<Tour, TourChange> with Deletable {
  List<TourAufzug> _aufzuege = [];
  final int _idx;
  final String _name;
  final DateTime _date;
  List<User> _sharedWith = [];
  List<Function(Tour)> _deleteListeners = [];

  Tour(this._idx, this._name, this._date, {List<TourAufzug>? aufzuege}) {
    if (aufzuege != null) {
      _aufzuege = aufzuege;
    }
  }

  Tour.dateOnly(DateTime date) : this(-1, "", date);

  Tour.fromApiJson(Map<String, dynamic> json, List<TourWorkType> workTypes)
      : _idx = json['idx'],
        _name = json['name'],
        _date = DateTime.parse(json['date']),
        this._sharedWith = List<User>.from(
            json['sharedWith'].map((e) => Users.get(e)).toList()) {
    this._aufzuege = List<TourAufzug>.from(json['afzs']
        .map((e) => TourAufzug.fromApiJson(this, e, workTypes))
        .toList());
  }

  int get idx => returnIfNotDeleted(_idx);
  String get name => returnIfNotDeleted(changeOr("name", _name));
  DateTime get date => returnIfNotDeleted(changeOr("date", _date));
  List<TourAufzug> get aufzuege =>
      returnIfNotDeleted(changeOr("aufzuege_", _aufzuege));
  List<User> get sharedWith =>
      returnIfNotDeleted(changeOr("sharedWith", _sharedWith));

  void set name(String name) {
    edit(TourChangeName(this._name, name));
  }

  void set date(DateTime date) {
    edit(TourChangeDate(this._date, date));
  }

  void set aufzuege(List<TourAufzug> aufzuege) {
    edit(TourChangeAufzuege(this._aufzuege, aufzuege));
  }

  bool isSameDay(DateTime date) {
    return this.date.year == date.year &&
        this.date.month == date.month &&
        this.date.day == date.day;
  }

  void addAufzug(Aufzug aufzug) {
    TourAufzug tourAufzug;
    if (aufzug is TourAufzug) {
      tourAufzug = aufzug;
    } else {
      tourAufzug = TourAufzug.fromAufzug(this, aufzug);
    }

    TourChange<dynamic>? afzChange =
        this.changes.firstWhereOrNull((element) => element.attr == "aufzuege");
    if (afzChange != null) {
      afzChange.newValue.add(tourAufzug);
    } else {
      edit(TourChangeAufzuege(this._aufzuege, [..._aufzuege, tourAufzug]));
    }
  }

  void moveAfz(TourAufzug afz, MoveDirection dir, {bool immediate = false}) {
    int idx = this._aufzuege.indexOf(afz);
    if (idx == -1) {
      throw Exception("Aufzug not in tour");
    }
    List<TourAufzug> afzList = _aufzuege;

    if (immediate) {
      WebComunicater.instance.tourModifyAfz(this, afz, dir: dir);
    } else {
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
      edit(TourChangeAufzuege(this._aufzuege, [..._aufzuege]..remove(aufzug)));
    }
  }

  void set sharedWith(List<User> sharedWith) {
    edit(TourChangeShared(this._sharedWith, sharedWith));
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
      edit(TourChangeShared(this._sharedWith, [..._sharedWith, user]));
    }
  }

  @override
  Future<Tour> create() async {
    Future<Tour> newTourFuture = WebComunicater.instance.createTourByTour(this);
    ToursHandler.instance.createTour(this);
    Tour newTour = await newTourFuture;
    ToursHandler.instance.updateTour(this, newTour);
    isDeleted = true;
    return newTour;
  }

  void addDeleteListener(Function(Tour) listener) {
    _deleteListeners.add(listener);
  }

  @override
  void delete() {
    for (Function(Tour) listener in _deleteListeners) {
      listener(this);
    }
    WebComunicater.instance.deleteTour(this);
    ToursHandler.instance.deleteTour(this);
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

    Tour newTour = Tour(
        this.idx, changes["name"] ?? this.name, changes["date"] ?? this.date,
        aufzuege: changes["aufzuege"] ?? this.aufzuege);

    ToursHandler.instance.updateTour(this, newTour);
    return newTour;
  }
}

//MARK: Tour Handler

class DateRange {
  final DateTime start;
  final DateTime end;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DateRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;

  bool isInRange(DateTime date) {
    return (date.isAfter(start) && date.isBefore(end)) ||
        date == start ||
        date == end;
  }

  DateRange(this.start, this.end);
  DateRange.month(DateTime date)
      : start = DateTime(date.year, date.month, 1),
        end = DateTime(date.year, date.month + 1, 0);
}

class ToursHandler {
  ToursHandler._();
  static final ToursHandler instance = ToursHandler._();

  Map<DateRange, List<Tour>> _tours = {};
  List<DateRange> _fetching = [];

  List<Tour>? _getFetchedTours(DateTime start, DateTime end) {
    return _tours[DateRange(start, end)];
  }

  bool alreadyFetched(DateTime start, DateTime end) {
    return _tours.containsKey(DateRange(start, end));
  }

  bool updateTour(Tour oldTour, Tour newTour) {
    if (!deleteTour(oldTour)) {
      return false;
    }
    return createTour(newTour);
  }

  bool createTour(Tour newTour) {
    DateRange newMonth = DateRange.month(newTour.date);
    if (!_tours.containsKey(newMonth)) {
      _tours[newMonth] = getchToursRange(newMonth, (f) => {});
    }
    _tours[newMonth]!.add(newTour);
    return true;
  }

  bool deleteTour(Tour tour) {
    DateRange month = DateRange.month(tour.date);
    if (!_tours.containsKey(month)) {
      return false;
    }
    if (!_tours[month]!.remove(tour)) {
      return false;
    }
    return true;
  }

  List<Tour> eventLoader(
      DateTime date, void Function(void Function()) updateParent) {
    DateRange month = DateRange.month(date);
    return fetchTours(month.start, month.end, updateParent)
        .where((element) => element.isSameDay(date))
        .toList();
  }

  List<Tour> getchToursRange(
      DateRange range, void Function(void Function()) updateParent) {
    return fetchTours(range.start, range.end, updateParent);
  }

  List<Tour> fetchTours(DateTime start, DateTime end,
      void Function(void Function()) updateParent) {
    if (alreadyFetched(start, end)) {
      return _getFetchedTours(start, end)!;
    }
    if (_fetching.contains(DateRange(start, end))) {
      return [];
    }

    Future<List<Tour>> futureTours =
        WebComunicater.instance.getTours(from: start, to: end);

    _fetching.add(DateRange(start, end));

    futureTours.then((value) {
      _tours[DateRange(start, end)] = value;
      _fetching.remove(DateRange(start, end));
      if (_fetching.isEmpty) {
        updateParent(() => {});
      }
    });
    return [];
  }
}
