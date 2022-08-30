import 'auto_key.dart';
import 'web_comunicater.dart';

class KeyChecker {
  KeyChecker._();
  static Future<String> checkKey(context) async {
    //print("CheckKey:");
    String response = await WebComunicater.sendRequest(<String, String>{});
    if (response == "notLoggedIn" || response.replaceAll("\n", "") != "true") {
      AuthKey.wrongKey(context);
      return "";
    }
    return "true";
  }
}
