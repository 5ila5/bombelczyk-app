import 'package:Bombelczyk/helperClasses/Arbeit.dart';
import 'package:Bombelczyk/helperClasses/Aufzug.dart';
import 'package:Bombelczyk/helperClasses/ToDo.dart';
import 'package:Bombelczyk/widgets/AufzugPage.dart';
import 'package:Bombelczyk/widgets/Clickables.dart';
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
  final void Function(BuildContext) onTap;
  final Color? backgroundColor;
  final List<Widget>? leftIcon;
  final List<Widget>? belowWidgets;

  AufzugBar(this.aufzug,
      {required this.onTap,
      this.rightIcon,
      this.backgroundColor,
      this.leftIcon,
      this.belowWidgets});

  AufzugBar.simpleOntap(this.aufzug,
      {void Function()? onTap,
      this.rightIcon,
      this.backgroundColor,
      this.leftIcon,
      this.belowWidgets})
      : this.onTap = ((BuildContext context) {
          if (onTap != null) onTap();
        });

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
                    onTap: () => this.onTap(context)),
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
            onTap: (c) => AufzugPageHandler.showPage(c, aufzug));
}

class TourAufzugBar extends AufzugBar<TourAufzug> {
  TourAufzugBar(
    TourAufzug aufzug,
    void Function(void Function()?) update,
  ) : super(aufzug,
            rightIcon: Column(
              children: [
                TourCheckIcon(aufzug, update),
                ClickableMapIcon(aufzug.address),
              ],
            ),
            onTap: (c) => AufzugPageHandler.showPage(c, aufzug));
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
  SimpleAufzugBarWithDistance(
    AufzugWithDistance aufzug,
  ) : super(aufzug,
            rightIcon: Column(children: [ClickableMapIcon(aufzug.address)]),
            onTap: (c) => AufzugPageHandler.showPage(c, aufzug));
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
  CollapsedToDoAufzugBar(
      AufzugWithToDos aufzug, void Function() uncollapse, BuildContext context)
      : super(aufzug,
            rightIcon: Column(children: [ClickableAfzIcon(context, aufzug)]),
            onTap: (c) => uncollapse(),
            leftIcon: [
              Icon(Icons.keyboard_arrow_up, color: Colors.blue),
              Padding(
                padding: const EdgeInsets.only(
                    right: 0, left: 5.0, bottom: 0, top: 0),
              )
            ]);
}

class UnCollapsedToDoAufzugBar extends AufzugBar<AufzugWithToDos> {
  final void Function(void Function()) update;

  UnCollapsedToDoAufzugBar(AufzugWithToDos aufzug, void Function() collapse,
      this.update, BuildContext context)
      : super(aufzug,
            rightIcon: Column(children: [ClickableAfzIcon(context, aufzug)]),
            onTap: (c) => collapse(),
            belowWidgets: ToDosBar.getToDoBars(aufzug, update),
            leftIcon: [
              Icon(Icons.keyboard_arrow_down, color: Colors.blue),
              Padding(
                padding: const EdgeInsets.only(
                    right: 0, left: 5.0, bottom: 0, top: 0),
              )
            ]);
}

class ToDosBar {
  static List<Widget> getAddTodoBar(
      AufzugWithToDos aufzug, final void Function(void Function()) update) {
    return [
      InkWell(
          child: Icon(Icons.add, size: 40, color: Colors.blue),
          onTap: () => update(() => aufzug.addTodo(
                ToDo(-1, aufzug, "", DateTime.now(), null),
              ))),
      Divider(thickness: 1, color: Colors.grey)
    ];
  }

  static List<Widget> getToDoBars(
      AufzugWithToDos aufzug, void Function(void Function()) update) {
    List<Widget> toReturn = getAddTodoBar(aufzug, update);
    for (ToDo todo in aufzug.todos) {
      void Function() informDelete = () {
        update(() {
          todo.delete();
        });
      };

      if (todo.id == -1) {
        toReturn.add(NewToDoBar(todo, informDelete));
      } else {
        toReturn.add(ToDoBar(todo, informDelete));
      }
      toReturn.add(Divider(thickness: 1, color: Colors.grey));
    }
    return toReturn;
  }
}

class WorkBar extends Table {
  WorkBar(Arbeit work)
      : super(
          children: [
            TableRow(children: [
              SelectableText("Datum"),
              SelectableText(work.dateString),
            ]),
            TableRow(children: [
              SelectableText("Monteur(e)"),
              SelectableText(work.workersString),
              //Text(value["MitarbeiterName"]),
            ]),
            TableRow(children: [
              SelectableText("Arbeit"),
              SelectableText(work.work),
            ]),
            TableRow(children: [
              SelectableText("Kurztext"),
              SelectableText(work.description),
            ]),
          ],
        );
}

class ToDoAufzugBar extends StatefulWidget {
  final AufzugWithToDos aufzug;
  final bool? initalCollapsed;

  ToDoAufzugBar(this.aufzug, [this.initalCollapsed]);

  @override
  _ToDoAufzugBarState createState() =>
      _ToDoAufzugBarState(aufzug, this.initalCollapsed);
}

class _ToDoAufzugBarState extends State<ToDoAufzugBar> {
  final AufzugWithToDos aufzug;
  bool collapsed = false;

  _ToDoAufzugBarState(this.aufzug, bool? initalCollapsed) {
    collapsed = initalCollapsed ?? false;
  }

  void collapse() {
    setState(() {
      collapsed = true;
    });
  }

  void uncollapse() {
    setState(() {
      collapsed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      return CollapsedToDoAufzugBar(aufzug, uncollapse, context);
    } else {
      return UnCollapsedToDoAufzugBar(aufzug, collapse, setState, context);
    }
  }
}
