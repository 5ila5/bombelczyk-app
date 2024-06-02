import 'dart:math';

import 'package:Bombelczyk/helperClasses/WebComunicator.dart';

class TourWorkType {
  final int _idx;
  final String _name;

  TourWorkType(this._idx, this._name);

  int get idx => _idx;
  String get name => _name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TourWorkType && other._idx == _idx && other._name == _name;
  }

  @override
  int get hashCode => _idx.hashCode ^ _name.hashCode;
}

class TourWorkTypes {
  static List<TourWorkType>? _types;
  static TourWorkType get defaultType =>
      _types!.reduce((curr, next) => curr.idx < next.idx ? curr : next);

  static Future<List<TourWorkType>> getTypes() {
    if (_types == null) {
      return WebComunicater.instance.getTourWorkTypes().then((value) {
        _types = value;
        return value;
      });
    }
    return Future.value(_types);
  }

  TourWorkTypes._();

  TourWorkType get(int idx) {
    return _types!.firstWhere((element) => element.idx == idx);
  }
}
