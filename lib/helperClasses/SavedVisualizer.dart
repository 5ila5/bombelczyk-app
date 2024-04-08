import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SavedVisualizer {
  static void showSavedVisualizer(BuildContext context) {
    final snackBar = SnackBar(
      content: Row(children: [
        Text('Gespeichert'),
        Icon(Icons.save_outlined, color: Colors.green)
      ]),
      //padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
      margin: EdgeInsets.fromLTRB(20, 0, 20, 30),
      duration: Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      //animation: new Animation(),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(color: Colors.grey)),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    HapticFeedback.heavyImpact();
  }
}
