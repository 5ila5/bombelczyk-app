import 'dart:async';

import 'package:Bombelczyk/helperClasses/WebComunicator.dart';

class User {
  final int _id;
  final String _name;

  User(this._id, this._name);

  int get id => _id;
  String get name => _name;

  @override
  String toString() {
    return "User $_id: $_name";
  }
}

class Users {
  static Future<List<User>>? _users;

  static Future<List<User>> getUsers() {
    if (_users == null) {
      _users = WebComunicater.instance.getUsers();
    }
    return _users!;
  }

  Users._();

  static Future<User> get(int id) {
    Future<List<User>> u = getUsers();
    return u.then((value) => value.firstWhere((element) => element.id == id));
  }

  static Future<List<User>> getMultiple(Iterable<int> ids) {
    return Future.wait(ids.map((e) => get(e)));
  }
}
