import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

class MyClass {
  final int a;
  final int b;

  MyClass(this.a, this.b);
}

void main() {
  List<MyClass> list = [MyClass(1, 2), MyClass(3, 4), MyClass(5, 6)];
  Map<int, int> map =
      Map.fromIterable(list, key: (e) => e.a, value: (e) => e.b);
}
