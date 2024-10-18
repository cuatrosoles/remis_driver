import 'dart:developer';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taxi_driver/main.dart';
import 'package:taxi_driver/network/RestApis.dart';
import 'package:taxi_driver/utils/Constants.dart';

class LocationService {
  static Future<void> startService() async {
    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onStart,
      ),
    );
  }

  static Future<void> onStart() async {
    final positionStream = Geolocator.getPositionStream();

    positionStream.listen((position) {
      // Aquí puedes emitir señales de geolocalización
      print(
          'Latitud en Background: ${position.latitude}, Longitud en Background: ${position.longitude}');

      Map req = {
        // "status": "active",
        "latitude": position.latitude.toString(),
        "longitude": position.longitude.toString(),
        "heading": position.heading - 90,
      };
      sharedPref.setDouble(LATITUDE, position.latitude);
      sharedPref.setDouble(LONGITUDE, position.longitude);
      sharedPref.setDouble(HEADING, position.heading - 90);
      updateStatus(req).then((value) {
        ///setState(() {});
      }).catchError((error) {
        log(error);
      });
    });
  }
}
