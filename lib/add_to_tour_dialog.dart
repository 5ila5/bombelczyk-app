import 'package:flutter/material.dart';
import 'tour_for_add_event.dart';

class AddToTourDialog extends StatefulWidget {
  final Map<String, dynamic> afz;

  const AddToTourDialog(
    this.afz, {
    Key? key,
  }) : super(key: key);

  @override
  AddToTourDialogState createState() => AddToTourDialogState();
}

class AddToTourDialogState extends State<AddToTourDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: SingleChildScrollView(
      child: TourForAddToEvent(widget.afz),
    ));
  }
}
