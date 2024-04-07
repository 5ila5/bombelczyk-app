import 'package:Bombelczyk/editable/Editable.dart';
import 'package:Bombelczyk/helperClasses/Aufzug.dart';
import 'package:Bombelczyk/helperClasses/WebComunicator.dart';

class ToDo extends Editable<ToDo, ToDoChange> with Deletable {
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

  int get id => returnIfNotDeleted(_id);
  Aufzug get aufzug => returnIfNotDeleted(_aufzug);
  String get text => returnIfNotDeleted(changeOr("text", _text));
  DateTime get creationDate => returnIfNotDeleted(_creationDate);
  DateTime? get doneDate => returnIfNotDeleted(changeOr("doneDate", _doneDate));
  bool get isDone => this.doneDate != null;

  void set done(bool done) {
    if (done) {
      edit(ToDoChange("doneDate", this._doneDate, DateTime.now()));
    } else {
      edit(ToDoChange("doneDate", this._doneDate, null));
    }
  }

  void set text(String text) {
    edit(ToDoChange("text", this._text, text));
  }

  @override
  Future<ToDo> create() {
    Future<ToDo> newTodo = WebComunicater.instance
        .createToDo(this._aufzug, this._text, this.isDone);
    this.isDeleted = true;
    return newTodo;
  }

  @override
  void delete() {
    WebComunicater.instance.deleteToDo(this);
    this.isDeleted = true;
  }

  @override
  ToDo save() {
    if (!this.hasChanged) {
      return this;
    }

    Map<String, dynamic> changes = {};

    for (ToDoChange change in this.changes) {
      if (change.isChanged) {
        changes[change.attr] = change.newValue;
      }
    }

    WebComunicater.instance.setToDo(
      this,
      done:
          changes.containsKey('doneDate') ? changes['doneDate'] != null : null,
      text: changes['text'],
    );

    this.isDeleted = true;

    return ToDo(
      this._id,
      this._aufzug,
      changes['text'] ?? this._text,
      this._creationDate,
      changes.containsKey('doneDate') ? changes['doneDate'] : this._doneDate,
    );
  }

  @override
  // TODO: implement original
  ToDo get original => ToDo(
      this._id, this._aufzug, this._text, this._creationDate, this._doneDate);
}
