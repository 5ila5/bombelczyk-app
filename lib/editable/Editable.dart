import 'package:Bombelczyk/helperClasses/Aufzug.dart';
import 'package:Bombelczyk/helperClasses/User.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';

abstract class Change<T> {
  final String _attr;
  final T? _oldValue;
  final Map<String, Type>? _allowedAttributes;
  T? _newValue;

  Change(this._attr, this._oldValue, this._newValue, [this._allowedAttributes]);

  String get attr => _attr;
  T? get oldValue => _oldValue;
  T? get newValue => _newValue;
  bool get isChanged => _oldValue != _newValue;

  void set newValue(T? newValue) {
    if (_allowedAttributes != null) {
      if (!_allowedAttributes!.containsKey(_attr)) {
        throw Exception("Invalid attribute");
      }
      Type t = _allowedAttributes![_attr]!;
      if (T != t) {
        throw Exception("Invalid type");
      }
    }
    _newValue = newValue;
  }
}

class TourChange<T> extends Change<T> {
  static final TOUR_ATTRS = {
    "aufzuege": List<TourAufzug>,
    "name": String,
    "date": DateTime,
    "sharedWith": List<User>,
  };

  TourChange(attr, oldValue, newValue)
      : super(attr, oldValue, newValue, TOUR_ATTRS);
}

class ToDoChange<T> extends Change<T> {
  static final TODO_ATTRS = {
    "text": String,
    "doneDate": DateTime,
  };

  ToDoChange(attr, oldValue, newValue)
      : super(attr, oldValue, newValue, TODO_ATTRS);
}

mixin Deletable {
  T returnIfNotDeleted<T>(T object) {
    if (this.isDeleted) {
      throw Exception("Object is deleted");
    }
    return object;
  }

  bool isDeleted = false;

  void delete() {
    isDeleted = true;
  }
}

abstract class Editable<T, C extends Change> {
  @protected
  List<C> changes = [];

  @protected
  void edit(C change) {
    C prevChange = changes.firstWhere(
        (element) => element.attr == change.attr && element.isChanged,
        orElse: () {
      changes.add(change);
      return change;
    });
    prevChange.newValue = change.newValue;
  }

  bool get hasChanged => changes.any((element) => element.isChanged);
  T get original;

  K changeOr<K>(String attr, K defaultValue) {
    C? change = changes.firstWhereOrNull((element) => element.attr == attr);
    if (change == null) {
      return defaultValue;
    }
    return change.newValue;
  }

  void cancel() {
    changes = [];
  }

  T save();
  void delete();
  Future<T> create();
}
