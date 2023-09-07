import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';

final locationDataProvider = StateProvider<LocationData?>((ref) {
  return null;
});

final locationDataFutureProvider = FutureProvider<LocationData?>((ref) async {
  Location location = Location();
  bool serviceEnabled;
  PermissionStatus permissionGranted;

  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return null;
    }
  }

  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return null;
    }
  }

  final currentLocation = await location.getLocation();
  ref.read(locationDataProvider.notifier).update((state) => currentLocation);
  return currentLocation;
});
