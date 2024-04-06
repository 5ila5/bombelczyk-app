abstract class SortType {
  String get name;
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
