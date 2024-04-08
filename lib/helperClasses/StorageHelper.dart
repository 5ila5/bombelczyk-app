import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  static setAuth(String token) async {
    return await (await prefs).setString("key", token);
  }

  static Future<String?> getAuth() {
    return prefs.then((value) => value.getString("key"));
  }

  static Future<List<int>> getHistory() {
    return prefs
        .then((value) => value.getStringList("lastAFZs"))
        .then((value) => value ?? [])
        .then((value) => value.map((e) => int.parse(e)).toList());
  }
}
