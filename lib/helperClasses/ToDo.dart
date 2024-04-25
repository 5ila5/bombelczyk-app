import 'package:Bombelczyk/editable/Editable.dart';
import 'package:Bombelczyk/helperClasses/Aufzug.dart';
import 'package:Bombelczyk/helperClasses/WebComunicator.dart';

class ToDo extends Editable<ToDo, ToDoChange> with Deletable {
  int _id;
  Aufzug _aufzug;
  String _text;
  DateTime _creationDate;
  DateTime? _doneDate;

  List<void Function(ToDo, ToDo)> replaceNotify = [];
  List<void Function(ToDo)> addNotify = [];
  List<void Function(ToDo)> deleteNotify = [];

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

  void registerListener(void Function(ToDo, ToDo) replaceNotify,
      void Function(ToDo) addNotify, void Function(ToDo) deleteNotify) {
    this.replaceNotify.add(replaceNotify);
    this.addNotify.add(addNotify);
    this.deleteNotify.add(deleteNotify);
  }

  void set isDone(bool done) {
    if (done) {
      edit(ToDoChangeDoneDate(this._doneDate, DateTime.now()));
    } else {
      edit(ToDoChangeDoneDate(this._doneDate, null));
    }
  }

  void set text(String text) {
    edit(ToDoChangeText(this._text, text));
  }

  @override
  Future<ToDo> create() {
    if (this.isDeleted) {
      throw Exception("ToDo is already created");
    }
    Future<ToDo> newTodo = WebComunicater.instance
        .createToDo(this._aufzug, this._text, this.isDone);

    newTodo.then((value) {
      this.addNotify.forEach((element) {
        element(value);
      });
    });

    this.isDeleted = true;
    return newTodo;
  }

  @override
  void delete() {
    WebComunicater.instance.deleteToDo(this);
    this.isDeleted = true;

    this.deleteNotify.forEach((element) {
      element(this);
    });
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

    ToDo newTodo = ToDo(
      this._id,
      this._aufzug,
      changes['text'] ?? this._text,
      this._creationDate,
      changes.containsKey('doneDate') ? changes['doneDate'] : this._doneDate,
    );

    this.replaceNotify.forEach((element) {
      element(this, newTodo);
    });
    return newTodo;
  }

  @override
  ToDo get original => ToDo(
      this._id, this._aufzug, this._text, this._creationDate, this._doneDate);
}
