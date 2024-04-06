import 'package:Bombelczyk/helperClasses/WebComunicator.dart';

class User {
  final int _id;
  final String _name;

  User(this._id, this._name);

  int get id => _id;
  String get name => _name;
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
    return _users!.firstWhere((element) => element.id == id);
  }
}
