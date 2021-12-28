import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'web_comunicater.dart';


class AuthKey {
  static final _passwordController = TextEditingController();

  static void wrongKey(BuildContext context) {
    displayTextInputDialog(context);
  }

  static void setKey(BuildContext context) async {
    //print("setKey");
    SharedPreferences prefs;
    if (Preferences.prefs == null) {
      prefs = await Preferences.initPrefs();
    } else {
      prefs = Preferences.prefs;
    }
    String pass = _passwordController.text;
    //print("pass:"+pass);
    if (pass.length < 1) {
      AuthKey.wrongKey(context);

      return;
    }
    String response = await WebComunicater.sendRequest(
        <String, String>{'password': pass},
        login: true);
    String respnse = response.replaceAll("\n", "");
    if (respnse == "false" || respnse.length != 32) {
      //print("false:");
      AuthKey.wrongKey(context);

      return;
    }

    prefs.setString("key", respnse);
  }

  static Future<void> displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Passwort:'),
            content: TextField(
              onSubmitted: (value) {
                setKey(context);
                Navigator.pop(context);
              },
              controller: _passwordController,
              decoration: InputDecoration(hintText: "Passwort"),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  elevation: 10.0,
                  shadowColor: Colors.blueGrey,
                  primary: Colors.white,
                  backgroundColor: Colors.blue,
                  onSurface: Colors.grey,
                ),
                child: Text('OK'),
                onPressed: () {
                  //setState(() {
                  //codeDialog = valueText;
                  setKey(context);
                  Navigator.pop(context);
                  //});
                },
              ),
            ],
          );
        });
  }
}