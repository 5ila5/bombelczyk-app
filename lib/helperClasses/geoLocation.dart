import 'package:Bombelczyk/helperClasses/Position.dart' as helper;
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class Geolocation {
  static Future<helper.Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
    } on MissingPluginException catch (_) {
      return helper.Position(49.768951, 8.635419);
    }

    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      //print('Location services are disabled.');
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        //print('Location permissions are permanently denied, we cannot request permissions.');
        return Future.error(
            'Keine berechtigung um auf Standort zuzugreifen, Wenn Sie diese Feature nutzen möchten ändern sie bitte ihre Einstellungen');
      }

      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        //print('Location permissions are denied');
        return Future.error('Keine berechtigung um auf Standort zuzugreifen');
      }
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position pos = await Geolocator.getCurrentPosition();

    return helper.Position(pos.latitude, pos.longitude);
  }
}
