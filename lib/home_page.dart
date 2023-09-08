import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:geofencing_demo/location_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(locationDataProvider).isLoading;
    final locationData = ref.watch(locationDataProvider).locationData;
    debugPrint("isLoading from build: $isLoading");
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Stay in the circle",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: isLoading == true
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 16,
                    ),
                    Text("Please wait. This might take some time.")
                  ],
                ),
              )
            : Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.width,
                  child: GoogleMap(
                    mapType: MapType.hybrid,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        locationData!.latitude!,
                        locationData.longitude!,
                      ),
                      zoom: 14.4746,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId("currentLocation"),
                        position: LatLng(
                            locationData.latitude!, locationData.longitude!),
                      ),
                      Marker(
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueGreen),
                        markerId: const MarkerId("geoFenceLocation"),
                        position: ref.watch(tappedLocationProvider) ??
                            LatLng(locationData.latitude!,
                                locationData.longitude!),
                      )
                    },
                    circles: {
                      Circle(
                        circleId: const CircleId("geo_fence_1"),
                        center: ref.watch(tappedLocationProvider) ??
                            LatLng(locationData.latitude!,
                                locationData.longitude!),
                        radius: 100,
                        fillColor: Colors.lightBlue.withOpacity(0.3),
                        strokeWidth: 0,
                      )
                    },
                    onTap: (latlng) {
                      ref
                          .read(tappedLocationProvider.notifier)
                          .update((state) => latlng);
                    },
                  ),
                ),
              ),
      ),
    );
  }
}

void startGeofenceService(LatLng latlng) {
  final geofenceService = GeofenceService.instance.setup(
      interval: 5000,
      accuracy: 100,
      loiteringDelayMs: 60000,
      statusChangeDelayMs: 10000,
      useActivityRecognition: true,
      allowMockLocations: true,
      printDevLog: false,
      geofenceRadiusSortType: GeofenceRadiusSortType.DESC);

  final geofenceList = <Geofence>[
    Geofence(
        id: "place_1",
        latitude: latlng.latitude,
        longitude: latlng.longitude,
        radius: [
          GeofenceRadius(id: "radius_1", length: 100),
          GeofenceRadius(id: "radius_2", length: 100),
          GeofenceRadius(id: "radius_3", length: 100),
          GeofenceRadius(id: "radius_4", length: 100),
        ])
  ];

  geofenceService
      .start(geofenceList)
      .catchError((e) => debugPrint("error: $e"));
}
