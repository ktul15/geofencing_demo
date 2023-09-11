import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geofencing_demo/location_data_state.dart';
import 'package:geofencing_demo/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

final currentUserLocationProvider =
    StateNotifierProvider<LocationDataNotifier, LocationDataState>((ref) {
  return LocationDataNotifier(ref: ref);
});

final geofenceLocationProvider = StateProvider<LatLng?>((ref) {
  return null;
});

class LocationDataNotifier extends StateNotifier<LocationDataState> {
  final dynamic ref;

  LocationDataNotifier({required this.ref})
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

    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData currentLocation;

    location.onLocationChanged.listen((newLocation) {
      debugPrint("location changed");
      state = state.copyWith(isLoading: false, locationData: newLocation);

      var currentLocation = ref.read(currentUserLocationProvider).locationData;
      var fenceCenter = ref.read(geofenceLocationProvider);
      double distance = getDistance(
          LatLng(currentLocation!.latitude!, currentLocation.longitude!),
          LatLng(fenceCenter!.latitude, fenceCenter.longitude));

      debugPrint("distance: $distance");

      if (distance < 100) {
        ref
            .read(userStatusProvider.notifier)
            .update((state) => "User is inside the circle");
      } else {
        ref
            .read(userStatusProvider.notifier)
            .update((state) => "User is outside the circle");
      }
    });

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

    currentLocation = await location.getLocation();
    debugPrint("location: $currentLocation");
    state = state.copyWith(isLoading: false, locationData: currentLocation);
    debugPrint("location: ${state.locationData}");
    debugPrint("isLoading: ${state.isLoading}");
  }
}

final markerSetProvider = StateProvider<Set<Marker>>((ref) {
  final locationData = ref.watch(currentUserLocationProvider).locationData;
  final tappedLocation = ref.watch(geofenceLocationProvider);

  // If user has tapped a location on the map, then show 2 markers, else show one.
  if (tappedLocation != null) {
    return {
      Marker(
        markerId: const MarkerId("currentLocation"),
        position: LatLng(locationData!.latitude!, locationData.longitude!),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId("geofenceLocation"),
        position: LatLng(tappedLocation.latitude, tappedLocation.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  } else if (locationData != null) {
    return {
      Marker(
        markerId: const MarkerId("currentLocation"),
        position: LatLng(locationData.latitude!, locationData.longitude!),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      )
    };
  } else {
    return {};
  }
});

final geofenceCircleProvider = StateProvider<Set<Circle>>((ref) {
  final locationData = ref.watch(geofenceLocationProvider);

  if (locationData != null) {
    return {
      Circle(
        circleId: const CircleId("geo_fence_1"),
        center: ref.watch(geofenceLocationProvider) ??
            LatLng(locationData.latitude, locationData.longitude),
        radius: 100,
        fillColor: Colors.lightBlue.withOpacity(0.3),
        strokeWidth: 0,
      )
    };
  } else {
    return {};
  }
});

final userStatusProvider = StateProvider<String?>((ref) {
  return null;
});
