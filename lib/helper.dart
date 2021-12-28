import 'web_comunicater.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'aufzug_page.dart';

enum Sorts {
  Aufzugsnummer,
  Strasse,
  Postleitzahl,
  Ort,
  Anfahrtszeit,
}
enum ToDoSorts {
  Aufzugsnummer,
  Strasse,
  Postleitzahl,
  Ort,
  Anfahrtszeit,
  Erledigt_Datum,
  Erstelldatum,
  ToDoText,
}

/*class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}*/


class Preferences {
  static SharedPreferences prefs;

  static Future<SharedPreferences> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    return prefs;
  }
}

class AufzugsArgumente {
  final Future<String> json;
  final String afzIdx;
  final String aNr;
  final String aStr;
  final String aPLZ;
  final String aOrt;
  final String aFZ;
  final String schluessel;

  AufzugsArgumente(this.afzIdx, this.aNr, this.json, this.aStr, this.aPLZ,
      this.aOrt, this.aFZ, this.schluessel);

  void printArgs() async {
    print("printArgs");
    print(await this.json);
    print("VERY IMPORTANT");
    //print(this.json.);
  }
}

class SelectElevator {
  static void selectElevator(String afzIdx, String nr, String str, String pLZ,
      String ort, String fZ, String schluessel, BuildContext context) async {
    SharedPreferences prefs;
    if (Preferences.prefs == null) {
      prefs = await Preferences.initPrefs();
    } else {
      prefs = Preferences.prefs;
    }

    Future<String> response = WebComunicater.sendRequest(<String, String>{
      'AfzIdx': afzIdx,
      'auth': prefs.getString("key"),
    });

    //Future<String> responseStr = response.replaceAll("\n", "");
    AufzugsArgumente args =
        AufzugsArgumente(afzIdx, nr, response, str, pLZ, ort, fZ, schluessel);
    args.printArgs();
    Navigator.pushNamed(
      context,
      Aufzug.aufzugRoute,
      arguments: args,
    );
  }
}