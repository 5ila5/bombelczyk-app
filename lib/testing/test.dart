import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;

class Aufzug {
  final int? afzIdx;

  Aufzug(this.afzIdx);
}

mixin Distance on Aufzug {
  double distance = -1;

  void setDistance(double distance) {
    this.distance = distance;
  }
}

class AufzugWithDistance extends Aufzug with Distance {
  AufzugWithDistance(int afzIdx, double distance) : super(afzIdx) {
    this.distance = distance;
  }
}

Future<String> test(int a) async {
  if (a == -1) {
    throw Exception("a is -1");
  }
  return "a is $a";
}

Future<String> test2(int a) async {
  return await test(a).then((value) => value + "!");
}

Future<String> test3(int a) {
  return test2(a).then((value) => value + "!");
}

void main() {
  // test3(0).then(print);
  // test3(-1)
  //     .then(print)
  //     .catchError((error, stackTrace) => print("Error: $error"));

  print(Uri.https("bombelczyk-aufzuege.de", "UpP0UH3nFKMsnJk2/login.php"));

  Map<String, int> map1 = {"a": 1, "b": 2};

  Map<String, dynamic> map2 = {...map1};

  map2["c"] = "hallo";
}
