abstract class SortType {
  String get name;
  List<SortType> get vals;

  List<String> get names;
}

class Sort {
  final SortType type;
  final SortDirection direction;
  Sort(this.type, this.direction);
}

enum AfzSortType implements SortType {
  ANR(name: "anr"),
  STREET(name: "astr"),
  ZIP(name: "plz"),
  CITY(name: "ort"),
  TRAVEL_TIME(name: "fk_zeit");

  final String name;

  List<AfzSortType> get vals => AfzSortType.values;
  List<String> get names => vals.map((e) => e.name).toList();
  const AfzSortType({required this.name});
}

enum ToDoSortType implements SortType {
  ANR(name: "anr"),
  STREET(name: "astr"),
  ZIP(name: "plz"),
  CITY(name: "ort"),
  TRAVEL_TIME(name: "fk_zeit"),
  DONE_DATE(name: "checked"),
  CREATION_DATE(name: "created"),
  TEXT(name: "text");

  final String name;
  const ToDoSortType({required this.name});
  List<ToDoSortType> get vals => ToDoSortType.values;

  List<String> get names => vals.map((e) => e.name).toList();
}

enum SortDirection {
  ASC,
  DESC;

  String toString() {
    return this == SortDirection.ASC ? "ASC" : "DESC";
  }
}

enum MoveDirection {
  UP,
  DOWN;

  String toString() {
    return this == MoveDirection.UP ? "up" : "down";
  }
}
