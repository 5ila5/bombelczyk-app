import 'package:Bombelczyk/helperClasses/Address.dart';
import 'package:Bombelczyk/helperClasses/Aufzug.dart';
import 'package:Bombelczyk/helperClasses/Tour.dart';
import 'package:Bombelczyk/helperClasses/User.dart';
import 'package:Bombelczyk/widgets/AufzugPage.dart';
import 'package:Bombelczyk/widgets/DropDownMenu.dart';
import 'package:Bombelczyk/widgets/ImgHandling.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:math';

class ClickableMapIcon extends InkWell {
  final Address address;

  ClickableMapIcon(this.address)
      : super(
          child: Icon(
            Icons.map_outlined,
            size: 50,
            color: Colors.blue,
          ),
          onTap: () {
            launchUrlString(
                "https://www.google.de/maps/search/?api=1&query=" +
                    address.street +
                    "+" +
                    address.houseNumber +
                    ",+" +
                    address.zipStr +
                    "+" +
                    address.city,
                mode: LaunchMode.externalNonBrowserApplication);
          },
        );
}

class ClickableAfzIcon extends InkWell {
  final Aufzug aufzug;

  ClickableAfzIcon(BuildContext context, this.aufzug)
      : super(
            child: Icon(
              Icons.elevator_outlined,
              size: 50,
              color: Colors.blue,
            ),
            onTap: () => AufzugPageHandler.showPage(context, aufzug));
}

class TourCheckIcon extends InkWell {
  final TourAufzug aufzug;
  final void Function(void Function()) updateParent;

  TourCheckIcon(this.aufzug, this.updateParent, {bool immediate = true})
      : super(
          child: Icon(
            Icons.check_circle,
            color: (aufzug.finished) ? Colors.grey : Colors.green,
            size: 50,
          ),
          onTap: () => updateParent(() {
            print(
                "Toggling finished for ${aufzug.anr} to ${!aufzug.finished} immediate: $immediate");
            if (immediate) {
              aufzug.finished = !aufzug.finished;
            } else {
              aufzug.setFinishedWithoutUpdate(!aufzug.finished);
            }
          }),
        );
}

class TourShowImage extends InkWell {
  final TourAufzug aufzug;

  TourShowImage(this.aufzug, BuildContext context)
      : super(
          child: Row(
            children: [
              Text(aufzug.amountImages.toString(),
                  style: TextStyle(fontSize: 20)),
              Icon(
                Icons.image_outlined,
                size: 50,
              )
            ],
          ),
          onTap: () => ImgHandling.showIMGs(context, aufzug.images),
        );
}

class ExpandAll extends InkWell {
  ExpandAll(bool collapsed, void Function(bool newCollapsed) clicked)
      : super(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: Transform.rotate(
                child: Icon(Icons.double_arrow, color: Colors.blue),
                angle: ((collapsed) ? 270 : 90) * pi / 180,
              )),
          onTap: () => clicked(!collapsed),
        );
}

class SaveInkWell extends InkWell {
  final void Function() save;

  SaveInkWell(this.save, bool changed)
      : super(
          child: Icon(Icons.save_outlined,
              size: 40, color: changed ? Colors.green : Colors.grey),
          onTap: changed ? save : () {},
        );
}

class CancelInkWell extends InkWell {
  final void Function() cancel;

  CancelInkWell(this.cancel, bool changed)
      : super(
          child: Icon(Icons.cancel_outlined,
              size: 40, color: changed ? Colors.red : Colors.grey),
          onTap: cancel,
        );
}

class DeleteInkWell extends InkWell {
  final void Function() delete;

  DeleteInkWell(this.delete)
      : super(
          child: Icon(Icons.delete_outlined, size: 40, color: Colors.red),
          onTap: delete,
        );
}

class MyButton extends ElevatedButton {
  MyButton(String text, void Function() onPressed, bool active)
      : super(
            child: Text(text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[active ? 400 : 200],
              elevation: 10,
              shape: const BeveledRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))),
            ),
            onPressed: (active) ? null : onPressed,
            statesController: (active)
                ? MaterialStatesController(Set.from([MaterialState.pressed]))
                : null);
}

class AddTour extends Container {
  AddTour({required void Function()? onPressed})
      : super(
          margin: EdgeInsets.only(right: 5, top: 5),
          alignment: Alignment.topRight,
          height: 40,
          child: FloatingActionButton.extended(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            onPressed: onPressed,
            label: Text("Neue Tour Anlegen"),
            icon: Icon(
              Icons.add_circle,
              color: Colors.black,

              //size: 35,
            ),
          ),
        );
}

class SmallIconButton extends Expanded {
  SmallIconButton(IconData icon, void Function()? onTap, Color? color)
      : super(
            flex: 1,
            child: InkWell(
              onTap: onTap,
              child: Icon(icon, color: color, size: 30),
            ));
}

class TourAufzugEditButtons {
  static ConstrainedBox getButtons(
      TourAufzug aufzug, void Function(void Function()) update) {
    return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 60, maxWidth: 100),
        child: Row(children: [
          if (!aufzug.isFirst)
            SmallIconButton(Icons.arrow_upward_outlined,
                () => update(() => aufzug.moveUp()), Colors.green),
          if (!aufzug.isLast)
            SmallIconButton(Icons.arrow_downward_outlined,
                () => update(() => aufzug.moveDown()), Colors.green),
          SmallIconButton(Icons.delete,
              () => update(() => aufzug.removeFromTour()), Colors.red),
        ]));
  }
}

class ShareButton extends StatelessWidget {
  final Tour tour;

  void _showShare(BuildContext context) async {
    MultiSelect select = MultiSelect<User>(
        items: await Users.getUsers(), selected: this.tour.sharedWith);
    List<User>? sharedWith = await (showDialog(
      context: context,
      builder: (c) {
        return select;
      },
    ));
    if (sharedWith != null) {
      this.tour.sharedWith = sharedWith;
    }
  }

  ShareButton(this.tour) : super();

  @override
  Widget build(BuildContext context) => InkWell(
      child: Container(
          child: Row(
            children: [Text("Teilen"), Icon(Icons.share, size: 30)],
          ),
          color: Colors.green),
      onTap: () => _showShare(
            context,
          ));
}

class TourEditBottomButtons extends StatelessWidget {
  final Tour tour;

  void _ok(BuildContext context) {
    if (tour.idx != -1) {
      tour.save();
    } else {
      tour.create();
    }
    Navigator.pop(context);
  }

  void _cancel(BuildContext context) {
    if (tour.idx != -1) {
      tour.cancel();
    } else {
      tour.delete();
    }

    Navigator.pop(context);
  }

  TourEditBottomButtons(this.tour) : super();
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
              flex: 1,
              child: FloatingActionButton(
                heroTag: "ok",
                onPressed: () => _ok(context),
                child: Text("OK"),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                backgroundColor: Colors.green,
              )),
          Expanded(
              flex: 2,
              child: Container(
                  padding: EdgeInsets.only(left: 10),
                  child: FloatingActionButton(
                    backgroundColor: Colors.red,
                    heroTag: "cancel",
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Abbrechen"),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  )))
        ],
      );
}
