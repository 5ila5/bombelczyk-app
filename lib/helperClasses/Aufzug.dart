import 'package:Bombelczyk/helperClasses/Address.dart';
import 'package:Bombelczyk/helperClasses/Arbeit.dart';
import 'package:Bombelczyk/helperClasses/Position.dart';
import 'package:Bombelczyk/helperClasses/SortTypes.dart';
import 'package:Bombelczyk/helperClasses/ToDo.dart';
import 'package:Bombelczyk/helperClasses/Tour.dart';
import 'package:Bombelczyk/helperClasses/TourWorkType.dart';
import 'package:Bombelczyk/helperClasses/WebComunicator.dart';
import 'package:flutter/cupertino.dart';

class Aufzug {
  final int _afzIdx;
  final String _anr;
  final String _fKZeit;
  final String _zgTxt;
  final Address _address;

  Aufzug(this._afzIdx, this._anr, this._fKZeit, this._zgTxt, this._address);

  Aufzug.fromApiJson(Map<String, dynamic> json)
      : this(json['AfzIdx'], json['Anr'], json['FK_zeit'] ?? "unknown",
            json['Zg_txt'], Address.fromApiJson(json));

  Aufzug.fromAufzug(Aufzug aufzug)
      : this(aufzug.afzIdx, aufzug.anr, aufzug.fKZeit, aufzug.zgTxt,
            aufzug.address);

  Address get address => _address;
  int get afzIdx => _afzIdx;
  String get anr => _anr;
  String get fKZeit => _fKZeit;
  String get zgTxt => _zgTxt;

  String _toStringSpecial(String type) {
    return "$type: $anr";
  }

  @override
  String toString() {
    return "Aufzug: $anr";
  }
}

class AufzugWithDistance extends Aufzug {
  final Distance _distance;

  AufzugWithDistance(int afzIdx, String anr, String fKZeit, String zgTxt,
      Address address, this._distance)
      : super(afzIdx, anr, fKZeit, zgTxt, address);
  Distance get distance => _distance;

  AufzugWithDistance.fromApiJson(Map<String, dynamic> json)
      : _distance = Distance.fromApiJson(json),
        super.fromApiJson(json);

  @override
  String toString() => _toStringSpecial("AufzugWithDistance");
}

class AufzugWithToDos extends Aufzug {
  List<ToDo> _todos = [];

  AufzugWithToDos(
      int afzIdx, String anr, String fKZeit, String zgTxt, Address address,
      {List<ToDo>? todos})
      : super(afzIdx, anr, fKZeit, zgTxt, address) {
    if (todos != null) {
      _todos = todos;
    }
  }

  AufzugWithToDos.fromApiJson(Map<String, dynamic> json)
      : super.fromApiJson(json) {
    if (json['todos'] != null) {
      _todos = List<ToDo>.from(
          json['todos'].map((e) => ToDo.fromApiJson(e, this)).toList());
    }
  }
  AufzugWithToDos.fromAufzug(Aufzug afz, List<ToDo> todos)
      : super(afz.afzIdx, afz.anr, afz.fKZeit, afz.zgTxt, afz.address) {
    _todos = todos;
    _todos.forEach((element) {
      element.registerListener(this.replaceToDo, this.addTodo, this.removeToDo);
    });
  }

  void addTodo(ToDo todo) {
    _todos.add(todo);
  }

  void replaceToDo(ToDo oldTodo, ToDo newTodo) {
    int index = _todos.indexOf(oldTodo);
    if (index != -1) {
      _todos[index] = newTodo;
    }
  }

  void removeToDo(ToDo todo) {
    _todos.remove(todo);
  }

  List<ToDo> get todos => _todos;

  @override
  String toString() => _toStringSpecial("AufzugWithToDos");
}

class DetailedAufzug extends AufzugWithToDos {
  List<Arbeit> _arbeiten = [];
  List<ToDo> _todos = [];

  DetailedAufzug(
      int afzIdx, String anr, Address address, String fKZeit, String zgTxt,
      {List<Arbeit>? arbeiten, List<ToDo>? todos})
      : super(afzIdx, anr, fKZeit, zgTxt, address, todos: todos) {
    if (arbeiten != null) {
      _arbeiten = arbeiten;
    }
  }
  DetailedAufzug.fromAufzugWithToDos(AufzugWithToDos afz, List<Arbeit> arbeiten)
      : super(afz.afzIdx, afz.anr, afz.fKZeit, afz.zgTxt, afz.address,
            todos: afz.todos) {
    _arbeiten = arbeiten;
  }

  void addArbeit(Arbeit arbeit) {
    _arbeiten.add(arbeit);
  }

  List<Arbeit> get arbeiten => _arbeiten;
  @override
  String toString() => _toStringSpecial("DetailedAufzug");
}

class TourAufzug extends Aufzug {
  bool _finished = false;
  TourWorkType _workType;
  Tour _tour;
  int _amount_images = 0;

  TourAufzug(this._tour, int afzIdx, String anr, String fKZeit, String zgTxt,
      Address address, this._workType,
      {int amountImages = 0, finished = false})
      : super(afzIdx, anr, fKZeit, zgTxt, address) {
    _amount_images = amountImages;
    _finished = finished;
  }

  TourAufzug.fromApiJson(
      this._tour, Map<String, dynamic> json, List<TourWorkType> workTypes)
      : _workType =
            workTypes.firstWhere((element) => element.idx == json['art']),
        _amount_images = json["anzImg"],
        super.fromApiJson(json);

  TourAufzug.fromAufzug(this._tour, Aufzug aufzug,
      {TourWorkType? workType, int amountImages = 0, finished = false})
      : this._workType = TourWorkTypes.defaultType,
        super.fromAufzug(aufzug);

  TourWorkType get workType => _workType;

  bool get hasImages => _amount_images > 0;
  int get amountImages => _amount_images;
  bool get finished => _finished;
  bool get isFirst => _tour.aufzuege.first == this;
  bool get isLast => _tour.aufzuege.last == this;

  void setFinishedWithoutUpdate(bool finished) {
    _finished = finished;
  }

  set finished(bool finished) {
    WebComunicater.instance.tourModifyAfz(_tour, this, done: finished);
    _finished = finished;
  }

  set workType(TourWorkType workType) {
    _workType = workType;
  }

  void moveUp({bool immediate = false}) {
    this._tour.moveAfz(this, MoveDirection.UP, immediate: immediate);
  }

  void moveDown({bool immediate = false}) {
    this._tour.moveAfz(
          this,
          MoveDirection.DOWN,
          immediate: immediate,
        );
  }

  void removeFromTour() {
    this._tour.removeAufzug(this);
  }

  Future<List<MemoryImage>> get images =>
      WebComunicater.instance.getTourAfzImages(_tour, this);

  @override
  String toString() => _toStringSpecial("TourAufzug");
}
