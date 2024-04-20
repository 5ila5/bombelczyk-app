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

  static void initWebComunicator() {
    print("initWebComunicator");
    WebComunicater(getAuth());
  }
}

class Login {
  static void _login(String password, BuildContext context) {
    WebComunicater.instance.login(password);
    Navigator.pop(context);
  }

  static final TextEditingController _controller = TextEditingController();

  static Future<void> displayLoginDialog(BuildContext context) async {
    return showDialog(
        context: context,
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
