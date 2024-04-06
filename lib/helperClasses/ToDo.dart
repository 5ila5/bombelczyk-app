import 'package:Bombelczyk/editable/Editable.dart';
import 'package:Bombelczyk/helperClasses/Aufzug.dart';

class ToDo extends Editable<ToDo, ToDoChange> {
  int _id;
  Aufzug _aufzug;
  String _text;
  DateTime _creationDate;
  DateTime? _doneDate;

  ToDo(this._id, this._aufzug, this._text, this._creationDate,
      [this._doneDate]);

  ToDo.fromApiJson(Map<String, dynamic> json, Aufzug aufzug)
      : this(
          json['idx'] is String ? int.parse(json['idx']) : json['idx'],
          aufzug,
          json['text'],
          DateTime.parse(json['created']),
          json['checked'] == null ? null : DateTime.parse(json['checked']),
        );

  int get id => _id;
  Aufzug get aufzug => _aufzug;
  String get text => _text;
  DateTime get creationDate => _creationDate;
  DateTime? get doneDate => _doneDate;
  bool get isDone => _doneDate != null;

  void set done(bool done) {
    if (done) {
      edit(ToDoChange("doneDate", this._doneDate, DateTime.now()));
    } else {
      edit(ToDoChange("doneDate", this._doneDate, null));
    }
  }

  @override
  Future<ToDo> create() {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  void delete() {
    // TODO: implement delete
  }

  @override
  ToDo save() {
    // TODO: implement save
    throw UnimplementedError();
  }
}
