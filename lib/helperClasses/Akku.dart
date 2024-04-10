import 'package:Bombelczyk/helperClasses/Aufzug.dart';

class Akku {
  final Aufzug _aufzug;
  final String _kapazitaet;
  final String _spannung;
  final String _ort;
  final int _menge;
  final DateTime _tauschTag;
  final String _zyklus;

  Akku(this._aufzug, this._kapazitaet, this._spannung, this._ort, this._menge,
      this._tauschTag, this._zyklus);

  Akku.fromApiJson(Map<String, dynamic> json, Aufzug aufzug)
      : this(
          aufzug,
          json['Kap'],
          json['Spg'],
          json['Ort'],
          json['Menge'],
          DateTime.parse(json['TauschTag']),
          json['Zykl'],
        );

  Aufzug get aufzug => _aufzug;
  String get kapazitaet => _kapazitaet;
  String get spannung => _spannung;
  String get ort => _ort;
  int get menge => _menge;
  DateTime get tauschTag => _tauschTag;
  String get zykl => _zyklus;
  int get zyklYears => int.parse(zykl.replaceAll(RegExp("[^\\d.]"), ""));
  DateTime get warningDate =>
      DateTime(tauschTag.year + zyklYears, tauschTag.month - 3, tauschTag.day);
  DateTime get dangerDate =>
      DateTime(tauschTag.year + zyklYears, tauschTag.month, tauschTag.day);

  bool get isWarning => warningDate.isBefore(DateTime.now());
  bool get isDanger => dangerDate.isBefore(DateTime.now());
}
