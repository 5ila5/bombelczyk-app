import 'package:Bombelczyk/helperClasses/Akku.dart';
import 'package:Bombelczyk/helperClasses/TimeFomratter.dart';
import 'package:Bombelczyk/widgets/MyFutureBuilder.dart';
import 'package:flutter/material.dart';

class AkkuTable extends Table {
  AkkuTable(Akku akku)
      : this._withRowColor(
            akku,
            akku.isDanger
                ? Colors.red
                : akku.isWarning
                    ? Colors.yellow
                    : Colors.green);

  AkkuTable._withRowColor(Akku akku, Color rowColor)
      : super(
          children: [
            TableRow(children: [
              Container(color: rowColor, child: Text("Menge")),
              Container(color: rowColor, child: Text(akku.menge.toString())),
            ]),
            TableRow(children: [
              Container(color: rowColor, child: Text("Letzter Wchsel")),
              Container(
                  color: rowColor,
                  child: Text(TimeFormatter.germanDateString(akku.tauschTag))),
            ]),
            TableRow(children: [
              Container(color: rowColor, child: Text("Spannung")),
              Container(color: rowColor, child: Text(akku.spannung)),
            ]),
            TableRow(children: [
              Container(color: rowColor, child: Text("Ort")),
              Container(color: rowColor, child: Text(akku.ort)),
            ]),
            TableRow(children: [
              Container(color: rowColor, child: Text("Kap")),
              Container(color: rowColor, child: Text(akku.kapazitaet)),
            ]),
            TableRow(children: [
              Container(color: rowColor, child: Text("Zyklus")),
              Container(color: rowColor, child: Text(akku.zykl)),
            ]),
            TableRow(children: [
              Divider(),
              Divider(),
            ]),
          ],
        );
}

class AkkuTableFutureBuilder
    extends CircularProgressIndicatorFutureBuilder<List<Akku>> {
  AkkuTableFutureBuilder(Future<List<Akku>> future)
      : super(
            future,
            (akkus) =>
                Column(children: [for (Akku akku in akkus) AkkuTable(akku)]));
}
