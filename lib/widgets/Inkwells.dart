import 'package:Bombelczyk/helperClasses/Address.dart';
import 'package:Bombelczyk/helperClasses/Aufzug.dart';
import 'package:Bombelczyk/widgets/ImgHandling.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ClickableMapIcon extends InkWell {
  Address address;

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
                    address.zip +
                    "+" +
                    address.city,
                mode: LaunchMode.externalNonBrowserApplication);
          },
        );
}

class TourCheckIcon extends InkWell {
  TourAufzug aufzug;
  void Function(void Function()?) updateParent;

  TourCheckIcon(this.aufzug, this.updateParent)
      : super(
          child: Icon(
            Icons.check_circle,
            color: (aufzug.finished) ? Colors.grey : Colors.green,
            size: 50,
          ),
          onTap: () => updateParent(() {
            aufzug.finished = !aufzug.finished;
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
