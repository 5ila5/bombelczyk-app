import 'dart:async';

import 'package:Bombelczyk/helperClasses/WebComunicator.dart';

class User {
  final int _id;
  final FutureOr<String> _name;

  User(this._id, this._name);

  int get id => _id;
  FutureOr<String> get name => _name;
}

class Users {
  static List<User>? _users;

  static Future<List<User>> getUsers() {
    if (_users == null) {
      return WebComunicater.instance.getUsers().then((value) {
        _users = value;
        return value;
      });
    }
    return Future.value(_users);
  }

  Users._();

  static User get(int id) {
    if (_users == null) {
      Future<List<User>> u = getUsers();
      return User(
          id,
          u.then(
              (value) => value.firstWhere((element) => element.id == id).name));
    }
    return _users!.firstWhere((element) => element.id == id);
  }
}
