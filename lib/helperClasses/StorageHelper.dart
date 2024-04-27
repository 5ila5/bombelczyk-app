import 'package:Bombelczyk/helperClasses/Aufzug.dart';
import 'package:Bombelczyk/helperClasses/WebComunicator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  static setAuth(String token) async {
    print("setAuth: $token");
    return await (await prefs).setString("key", token);
  }

  static Future<String?> getAuth() {
    print("getAuth");
    return prefs.then((value) => value.getString("key"));
  }

  static Future<List<int>> getHistory() {
    return prefs
        .then((value) => value.getStringList("lastAFZs"))
        .then((value) => value ?? [])
        .then((value) => value.map((e) => int.parse(e)).toList());
  }

  static Future<void> _setHistory(List<int> history) {
    return prefs.then((value) => value.setStringList(
        "lastAFZs", history.map((e) => e.toString()).toList()));
  }

  static Future<void> addHistory(Aufzug afz) {
    return getHistory().then((value) {
      value.remove(afz.afzIdx);
      if (value.length > 15) {
        value.removeLast();
      }
      value.insert(0, afz.afzIdx);
      return _setHistory(value);
    });
  }

  static void initWebComunicator() {
    print("initWebComunicator");
    WebComunicater(getAuth());
  }
}

class Login {
  static void _login(String password, BuildContext context) {
    Navigator.pop(context, WebComunicater.instance.login(password));
  }

  static final TextEditingController _controller = TextEditingController();

  static Future<bool?> displayLoginDialog(BuildContext parentContext) async {
    return await showDialog<Future<bool?>?>(
        context: parentContext,
        builder: (context) {
          return AlertDialog(
            title: Text('Passwort:'),
            content: TextField(
              onSubmitted: (value) => _login(value, context),
              decoration: InputDecoration(hintText: "Passwort"),
              controller: _controller,
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  elevation: 10.0,
                  shadowColor: Colors.blueGrey,
                  disabledForegroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                ),
                child: Text('OK'),
                onPressed: () => _login(_controller.text, context),
              ),
            ],
          );
        });
  }
}
