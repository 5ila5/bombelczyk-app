class Position {
  final double latitude;
  final double longitude;
  Position(this.latitude, this.longitude);
}

class Distance {
  final double _distance;

  Distance(this._distance);

  Distance.fromApiJson(Map<String, dynamic> json)
      : _distance = json['distance'];

  double get distance => _distance;

  String get distnaceString => _distance > 1.0
      ? _distance.toStringAsFixed(2).replaceAll(".", ",") + " km"
      : (_distance * 1000.0).toString() + " m";

  @override
  String toString() {
    return distnaceString;
  }
}
