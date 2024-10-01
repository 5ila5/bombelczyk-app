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
        print("T: $T, t: $t");
        throw Exception("Invalid type");
      }
    }
    _newValue = newValue;
  }

  @override
  String toString() {
    return "$_attr: $_oldValue -> $_newValue";
  }
}

class TourChange<T> extends Change<T> {
  static final TOUR_ATTRS = {
    "aufzuege": List<TourAufzug>,
    "name": String,
    "date": DateTime,
    "sharedWith": List<User>,
  };

  TourChange._(String attr, T oldValue, T newValue)
      : super(attr, oldValue, newValue);
}

class TourChangeAufzuege extends TourChange<List<TourAufzug>> {
  TourChangeAufzuege(List<TourAufzug> oldValue, List<TourAufzug> newValue)
      : super._("aufzuege", oldValue, newValue);
}

class TourChangeName extends TourChange<String> {
  TourChangeName(String oldValue, String newValue)
      : super._("name", oldValue, newValue);
}

class TourChangeDate extends TourChange<DateTime> {
  TourChangeDate(DateTime oldValue, DateTime newValue)
      : super._("date", oldValue, newValue);
}

class TourChangeShared extends TourChange<List<Future<User>>> {
  TourChangeShared(List<Future<User>> oldValue, List<Future<User>> newValue)
      : super._("sharedWith", oldValue, newValue);
}

class ToDoChange<T> extends Change<T> {
  static final TODO_ATTRS = {
    "text": String,
    "doneDate": DateTime,
  };

  ToDoChange._(attr, oldValue, newValue)
      : super(attr, oldValue, newValue, TODO_ATTRS);
}

class ToDoChangeText extends ToDoChange<String> {
  ToDoChangeText(String oldValue, String newValue)
      : super._("text", oldValue, newValue);
}

class ToDoChangeDoneDate extends ToDoChange<DateTime?> {
  ToDoChangeDoneDate(DateTime? oldValue, DateTime? newValue)
      : super._("doneDate", oldValue, newValue);
}

mixin Deletable {
  T returnIfNotDeleted<T>(T object) {
    if (this.isDeleted) {
      throw Exception("Object is deleted");
    }
    return object;
  }

  bool _isDeleted = false;
  bool get isDeleted => _isDeleted;

  void delete() {
    _isDeleted = true;
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
