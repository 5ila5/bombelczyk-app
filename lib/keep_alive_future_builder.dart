import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class KeepAliveFutureBuilder extends StatefulWidget {
  final Future? future;
  final AsyncWidgetBuilder builder;

  KeepAliveFutureBuilder({this.future, required this.builder});

  @override
  _KeepAliveFutureBuilderState createState() => _KeepAliveFutureBuilderState();
}

class _KeepAliveFutureBuilderState extends State<KeepAliveFutureBuilder>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: widget.future,
      builder: widget.builder,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
