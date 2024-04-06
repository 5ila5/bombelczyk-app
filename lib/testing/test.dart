import 'package:collection/collection.dart';

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

void main() {
  List<String> list = ["a", "b", "c"];

  print(list.map((e) => e + "a"));
  List<int> numbers = [1, 2, 3, 4, 5];

  int? firstEven = numbers.firstWhereOrNull((number) => number % 2 == 0);
}
