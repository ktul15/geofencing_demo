import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:geofencing_demo/location_provider.dart';
import 'package:geofencing_demo/services/geofence_service.dart';
import 'package:geofencing_demo/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as Location;

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Location.Location location = Location.Location();

  @override
  void initState() {
    super.initState();
    ref.read(geofenceServiceProvider).startService();

    location.onLocationChanged.listen((event) {
      debugPrint("location changed");

      var currentLocation = ref.read(currentUserLocationProvider).locationData;
      var fenceCenter = ref.read(geofenceLocationProvider);

      if (currentLocation != null && fenceCenter != null) {
        double distance = getDistance(
            LatLng(currentLocation.latitude!, currentLocation.longitude!),
            LatLng(fenceCenter.latitude, fenceCenter.longitude));

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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(currentUserLocationProvider).isLoading;
    final locationData = ref.watch(currentUserLocationProvider).locationData;

    late Set<Marker> markers = ref.watch(markerSetProvider);
    final Set<Circle> geofenceCircle = ref.watch(geofenceCircleProvider);

    final userStatus = ref.watch(userStatusProvider);

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
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      "currentLocation: ${ref.watch(currentUserLocationProvider).locationData}"),
                  Text(userStatus ?? ""),
                  const SizedBox(
                    height: 16,
                  ),
                  SizedBox(
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

                        //add geofence to list
                        ref.read(geofenceServiceProvider).addGeofence(Geofence(
                                id: "fence_1",
                                latitude: latlng.latitude,
                                longitude: latlng.longitude,
                                radius: [
                                  GeofenceRadius(id: "radius_1", length: 50),
                                  GeofenceRadius(id: "radius_2", length: 50),
                                  GeofenceRadius(id: "radius_3", length: 50),
                                  GeofenceRadius(id: "radius_4", length: 50),
                                ]));

                        // check if the user is in the geofence or not
                        var currentLocation =
                            ref.read(currentUserLocationProvider).locationData;
                        var fenceCenter = ref.read(geofenceLocationProvider);
                        bool isUserInside = isUserInsideFence(
                            LatLng(currentLocation!.latitude!,
                                currentLocation.longitude!),
                            LatLng(
                                fenceCenter!.latitude, fenceCenter.longitude));

                        if (isUserInside) {
                          ref
                              .read(userStatusProvider.notifier)
                              .update((state) => "User is inside the circle");
                        } else {
                          ref
                              .read(userStatusProvider.notifier)
                              .update((state) => "User is outside the circle");
                        }
                      },
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
