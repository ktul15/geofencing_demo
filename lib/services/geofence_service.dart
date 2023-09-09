import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geofence_service/geofence_service.dart';

final geofenceServiceProvider = Provider<CustomGeofenceService>((ref) {
  return CustomGeofenceService();
});

class CustomGeofenceService {
  late final geofenceService;
  late List<Geofence> geofenceList;

  void startService() {
    geofenceService = GeofenceService.instance.setup(
        interval: 5000,
        accuracy: 100,
        loiteringDelayMs: 60000,
        statusChangeDelayMs: 10000,
        useActivityRecognition: true,
        allowMockLocations: true,
        printDevLog: false,
        geofenceRadiusSortType: GeofenceRadiusSortType.DESC);

    geofenceService
        .start()
        .catchError((e) => debugPrint("Error from geofence Service: $e"));
    debugPrint("geofenceservice: $geofenceService");
  }

  void addGeofence(Geofence geofence) {
    geofenceList.removeAt(0);
    geofenceList.add(geofence);
  }
}
