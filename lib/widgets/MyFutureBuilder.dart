import 'package:Bombelczyk/helperClasses/StorageHelper.dart';
import 'package:Bombelczyk/helperClasses/WebComunicator.dart';
import 'package:flutter/material.dart';

class CircularProgressIndicatorFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(T) onData;

  CircularProgressIndicatorFutureBuilder(this.future, this.onData) : super();

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        Widget toReturn;
        if (snapshot.hasData) {
          toReturn = onData(snapshot.data!);
        } else if (snapshot.hasError) {
          if (snapshot.error is WrongAuthException) {
            Login.displayLoginDialog(context);
          }
          toReturn = Text("${snapshot.error}");
        } else {
          toReturn = CircularProgressIndicator();
        }
        return toReturn;
      });
}

class ColumnFutureBuilder<T> extends FutureBuilder<T> {
  static List<Widget> onLoad() {
    return const <Widget>[
      SizedBox(
        child: CircularProgressIndicator(),
        width: 60,
        height: 60,
      ),
      Padding(
        padding: EdgeInsets.only(top: 16),
        child: Text('Läd einträge...'),
      )
    ];
  }

  static Widget myBuilder<R>(BuildContext context, AsyncSnapshot<R> snapshot,
      List<Widget> Function(R) onData) {
    List<Widget> children = [];
    if (snapshot.hasData) {
      children = onData(snapshot.data!);
    } else if (snapshot.hasError) {
      if (snapshot.error is WrongAuthException) {
        Login.displayLoginDialog(context);
      }

      children = <Widget>[
        const Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 60,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text('Error: ${snapshot.error}'),
        )
      ];
    } else {
      children = onLoad();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

  ColumnFutureBuilder(Future<T> future, List<Widget> Function(T) onData)
      : super(
            future: future,
            builder: (context, snapshot) =>
                myBuilder<T>(context, snapshot, onData));
}

class WidgetColumnFutureBuilder extends ColumnFutureBuilder<List<Widget>> {
  WidgetColumnFutureBuilder(Future<List<Widget>> future)
      : super(future, (data) => data);
}
