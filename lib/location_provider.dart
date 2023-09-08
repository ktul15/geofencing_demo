import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geofencing_demo/location_data_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

final locationDataProvider =
    StateNotifierProvider<LocationDataNotifier, LocationDataState>((ref) {
  return LocationDataNotifier();
});

final tappedLocationProvider = StateProvider<LatLng?>((ref) {
  return null;
});

class LocationDataNotifier extends StateNotifier<LocationDataState> {
  LocationDataNotifier()
      : super(
          LocationDataState(
            locationData: null,
            isLoading: true,
            error: "",
          ),
        ) {
    debugPrint("calling getLocation");
    getLocation();
  }

  Future<void> getLocation() async {
    state = state.copyWith(isLoading: true);
    // debugPrint("isLoading ${state.isLoading}");

    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        debugPrint("in service error");
        state = state.copyWith(isLoading: false, error: "Service denied");
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        debugPrint("in permission error");
        state = state.copyWith(isLoading: false, error: "Permission denied");
        return;
      }
    }

    final currentLocation = await location.getLocation();
    debugPrint("location: $currentLocation");
    state = state.copyWith(isLoading: false, locationData: currentLocation);
    debugPrint("location: ${state.locationData}");
    debugPrint("isLoading: ${state.isLoading}");
  }
}
