import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

bool isUserInsideFence(LatLng currentLocation, LatLng fenceCenter) {
  double distance = getDistance(
      LatLng(currentLocation.latitude, currentLocation.longitude),
      LatLng(fenceCenter.latitude, fenceCenter.longitude));

  debugPrint("distance: $distance");

  if (distance < 100) {
    return true;
  } else {
    return false;
  }
}

double getDistance(LatLng userLocation, LatLng fenceCenter) {
  double lat1 = userLocation.latitude;
  double lon1 = userLocation.longitude;
  double lat2 = fenceCenter.latitude;
  double lon2 = fenceCenter.longitude;

  var R = 6371e3; // metres
  // var R = 1000;
  var phi1 = (lat1 * pi) / 180; // φ, λ in radians
  var phi2 = (lat2 * pi) / 180;
  var deltaPhi = ((lat2 - lat1) * pi) / 180;
  var deltaLambda = ((lon2 - lon1) * pi) / 180;

  var a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
      cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);

  var c = 2 * atan2(sqrt(a), sqrt(1 - a));

  var d = R * c; // in metres

  return d;
}
