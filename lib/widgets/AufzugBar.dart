import 'package:Bombelczyk/helperClasses/Aufzug.dart';
import 'package:Bombelczyk/helperClasses/ToDo.dart';
import 'package:Bombelczyk/widgets/AufzugPage.dart';
import 'package:Bombelczyk/widgets/Inkwells.dart';
import 'package:Bombelczyk/widgets/Styles.dart';
import 'package:Bombelczyk/widgets/ToDoBar.dart';
import 'package:flutter/material.dart';

class AufzugBarRow extends Row {
  AufzugBarRow(String text)
      : super(
          children: [
            //Text(widget.plz + " ", style: tableRowBottomStyle,overflow: TextOverflow.fade,),
            Flexible(
              child: Text(
                text,
                style: AufzugBarBodyTextStyle(),
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        );
}

class AufzugBar<AufzugType extends Aufzug> extends StatelessWidget {
  final AufzugType aufzug;
  final Widget? rightIcon;
  final void Function()? onTap;
  final Color? backgroundColor;
  final List<Widget>? leftIcon;
  final List<Widget>? belowWidgets;

  AufzugBar(this.aufzug,
      {this.onTap,
      this.rightIcon,
      this.backgroundColor,
      this.leftIcon,
      this.belowWidgets});

  List<String> getBodyTexts() {
    List<String> toReturn = [
      aufzug.anr +
          "  " +
          aufzug.address.street +
          " " +
          aufzug.address.houseNumber,
      aufzug.address.zip + " " + aufzug.address.city,
      "Anfahrt " + aufzug.fKZeit,
    ];

    if (aufzug.zgTxt.length > 2) {
      toReturn.add("Schlüssel " + aufzug.zgTxt);
    }
    return toReturn;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.only(right: 20.0, left: 10.0, bottom: 5.0, top: 5.0),
      //padding: const EdgeInsets.only(left: 10.0),
      color: backgroundColor,
      child: Column(
        children: [
          if (leftIcon != null) ...leftIcon!,
          Row(
            children: [
              Expanded(
                child: new InkWell(
                    child: Column(
                      children:
                          getBodyTexts().map((e) => AufzugBarRow(e)).toList(),
                    ),
                    onTap: this.onTap),
              ),
              if (rightIcon != null) rightIcon!,
            ],
          ),
          //Divider(thickness: 0.0),
          if (belowWidgets != null) ...belowWidgets!,
        ],
      ),
    );
  }
}

class SimpleAufzugBar extends AufzugBar<Aufzug> {
  SimpleAufzugBar(Aufzug aufzug)
      : super(aufzug,
            rightIcon: Column(children: [ClickableMapIcon(aufzug.address)]),
            onTap: () => AufzugPage.showPage(aufzug));
}

class TourAufzugBar extends AufzugBar<TourAufzug> {
  TourAufzugBar(TourAufzug aufzug, void Function(void Function()?) update)
      : super(aufzug,
            rightIcon: Column(
              children: [
                TourCheckIcon(aufzug, update),
                ClickableMapIcon(aufzug.address),
              ],
            ),
            onTap: () => AufzugPage.showPage(aufzug));
}

mixin DistanceText on AufzugBar<AufzugWithDistance> {
  List<String> getBodyTexts() {
    List<String> toReturn = super.getBodyTexts();
    toReturn.add("Entfernung: " + aufzug.distance.distnaceString);
    return toReturn;
  }
}

class SimpleAufzugBarWithDistance extends AufzugBar<AufzugWithDistance>
    with DistanceText {
  SimpleAufzugBarWithDistance(AufzugWithDistance aufzug)
      : super(aufzug,
            rightIcon: Column(children: [ClickableMapIcon(aufzug.address)]),
            onTap: () => AufzugPage.showPage(aufzug));
}

class TourAufzugBarWithState extends StatefulWidget {
  final TourAufzug aufzug;

  TourAufzugBarWithState(this.aufzug);

  @override
  _TourAufzugBarWithStateState createState() =>
      _TourAufzugBarWithStateState(aufzug);
}

class _TourAufzugBarWithStateState extends State<TourAufzugBarWithState> {
  final TourAufzug aufzug;

  _TourAufzugBarWithStateState(this.aufzug);

  void update(void Function()? update) {
    setState(update ?? () {});
  }

  @override
  Widget build(BuildContext context) {
    return TourAufzugBar(aufzug, update);
  }
}

class CollapsedToDoAufzugBar extends AufzugBar<AufzugWithToDos> {
  CollapsedToDoAufzugBar(AufzugWithToDos aufzug, void Function() uncollapse)
      : super(aufzug,
            rightIcon: Column(children: [ClickableAfzIcon(aufzug)]),
            onTap: uncollapse,
            leftIcon: [
              Icon(Icons.keyboard_arrow_up, color: Colors.blue),
              Padding(
                padding: const EdgeInsets.only(
                    right: 0, left: 5.0, bottom: 0, top: 0),
              )
            ]);
}

class UnCollapsedToDoAufzugBar extends AufzugBar<AufzugWithToDos> {
  UnCollapsedToDoAufzugBar(AufzugWithToDos aufzug, void Function() collapse,
      void Function() uncollapse)
      : super(aufzug,
            rightIcon: Column(children: [ClickableAfzIcon(aufzug)]),
            onTap: collapse,
            belowWidgets: [
              for (ToDo todo in aufzug.todos) ToDoBar(todo, collapse)
            ],
            leftIcon: [
              Icon(Icons.keyboard_arrow_down, color: Colors.blue),
              Padding(
                padding: const EdgeInsets.only(
                    right: 0, left: 5.0, bottom: 0, top: 0),
              )
            ]);
}
