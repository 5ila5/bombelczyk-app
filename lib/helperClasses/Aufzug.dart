import 'package:Bombelczyk/helperClasses/Address.dart';
import 'package:Bombelczyk/helperClasses/Arbeit.dart';
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
      : this(json['AfzIdx'], json['Anr'], json['FK_zeit'], json['Zg_txt'],
            Address.fromApiJson(json));

  Address get address => _address;
  int get afzIdx => _afzIdx;
  String get anr => _anr;
  String get fKZeit => _fKZeit;
  String get zgTxt => _zgTxt;
}

class AufzugWithDistance extends Aufzug {
  final double _distance;

  AufzugWithDistance(int afzIdx, String anr, String fKZeit, String zgTxt,
      Address address, this._distance)
      : super(afzIdx, anr, fKZeit, zgTxt, address);
  double get distance => _distance;

  AufzugWithDistance.fromApiJson(Map<String, dynamic> json)
      : _distance = json['distance'],
        super.fromApiJson(json);
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
  }

  void addTodo(ToDo todo) {
    _todos.add(todo);
  }

  List<ToDo> get todos => _todos;
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
}

class TourAufzug extends Aufzug {
  TourWorkType _workType;
  Tour _tour;
  bool _has_images = false;

  TourAufzug(this._tour, int afzIdx, String anr, String fKZeit, String zgTxt,
      Address address, this._workType,
      {bool hasImages = false})
      : super(afzIdx, anr, fKZeit, zgTxt, address) {
    _has_images = hasImages;
  }

  TourAufzug.fromApiJson(
      this._tour, Map<String, dynamic> json, List<TourWorkType> workTypes)
      : _workType =
            workTypes.firstWhere((element) => element.idx == json['art']),
        _has_images = json["anzImg"] > 0,
        super.fromApiJson(json);

  TourWorkType get workType => _workType;

  bool get hasImages => _has_images;

  Future<List<MemoryImage>>? get images =>
      WebComunicater.instance.getTourAfzImages(_tour, this);
}
