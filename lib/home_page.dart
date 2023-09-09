import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:geofencing_demo/location_provider.dart';
import 'package:geofencing_demo/services/geofence_service.dart';
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
  void initState() {
    super.initState();
    ref.read(geofenceServiceProvider).startService();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(currentUserLocationProvider).isLoading;
    final locationData = ref.watch(currentUserLocationProvider).locationData;

    late Set<Marker> markers = ref.watch(markerSetProvider);

    final Set<Circle> geofenceCircle = ref.watch(geofenceCircleProvider);

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
                  height: MediaQuery.of(context).size.height * 0.5,
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
                    markers: markers,
                    circles: geofenceCircle,
                    onTap: (latlng) {
                      // save geofence location
                      ref
                          .read(geofenceLocationProvider.notifier)
                          .update((state) => latlng);
                      ref.read(geofenceServiceProvider).addGeofence(Geofence(
                              id: "fence_1",
                              latitude: latlng.latitude,
                              longitude: latlng.longitude,
                              radius: [
                                GeofenceRadius(id: "radius_1", length: 100),
                                GeofenceRadius(id: "radius_2", length: 100),
                                GeofenceRadius(id: "radius_3", length: 100),
                                GeofenceRadius(id: "radius_4", length: 100),
                              ]));
                      startGeofenceService(latlng);
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
  debugPrint(geofenceService.toString());
}
