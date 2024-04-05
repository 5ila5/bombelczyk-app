import 'package:flutter/material.dart';
import 'keep_alive_future_builder.dart';
import 'dart:convert';
import 'arbeiten.dart';

class WorkList extends StatefulWidget {
  WorkList(this.response, {Key? key}) : super(key: key);
  final Future<String> response;

  @override
  WorkListState createState() => WorkListState();
}

class WorkListState extends State<WorkList> {
  Widget? arbeit;
  @override
  Widget build(BuildContext context) {
    if (arbeit != null) {
      return arbeit!;
    }
    return KeepAliveFutureBuilder(
      future: widget.response,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        List<Widget> children = [];
        if (snapshot.hasData) {
          //children = snapshot.data;
          Map<String, dynamic> responseMap =
              Map<String, dynamic>.from(jsonDecode(snapshot.data));

          if (!(responseMap["1"].runtimeType == String ||
              responseMap["1"]["error"] == "true")) {
            Map<String, dynamic> arbeitMap = responseMap["1"];
            arbeitMap.remove("error");
            //print("arbeitMap".toString());
            //print(arbeitMap.toString());
            arbeit = Arbeiten(arbeitMap);
            return arbeit!;
          } else {
            return ListView.builder(
              itemCount: 0,
              itemBuilder: (context, index) => children[index],
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
            );
          }
        } else if (snapshot.hasError) {
          children.addAll(
            [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              )
            ],
          );
        } else {
          children.addAll(
            const <Widget>[
              SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Läd einträge...'),
              )
            ],
          );
        }
        return ListView.builder(
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
          physics: ClampingScrollPhysics(),
          shrinkWrap: true,
        );
      },
//          }
    );
  }
}
