class Address {
  final String _street;
  final String _houseNumber;
  final int _zip;
  final String _city;

  Address(this._street, this._houseNumber, this._zip, this._city);

  Address.fromJson(Map<String, dynamic> json)
      : this(
          json['street'],
          json['hNr'],
          json['zip'],
          json['city'],
        );

  Address.fromApiJson(Map<String, dynamic> json)
      : this(
          json['Astr'],
          json['Ahnr'],
          json['plz'],
          json['Ort'],
        );

  Map<String, dynamic> toJson() {
    return {
      'street': _street,
      'hNr': _houseNumber,
      'zip': _zip,
      'city': _city,
    };
  }

  String get street => _street;
  String get houseNumber => _houseNumber;
  int get zip => _zip;
  String get zipStr => _zip.toString();
  String get city => _city;
}
