import 'package:Bombelczyk/helperClasses/Aufzug.dart';
import 'package:Bombelczyk/widgets/AufzugPage.dart';
import 'package:Bombelczyk/widgets/Inkwells.dart';
import 'package:Bombelczyk/widgets/Styles.dart';
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

  AufzugBar(this.aufzug, {this.onTap, this.rightIcon, this.backgroundColor});

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
