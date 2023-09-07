import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Stay in the circle",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: ref.watch(locationDataFutureProvider).when(
            data: (data) {
              final latitude = data!.latitude!;
              final longitude = data.longitude!;
              return Center(
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
                        data.latitude!,
                        data.longitude!,
                      ),
                      zoom: 14.4746,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId("currentLocation"),
                        position: LatLng(latitude, longitude),
                      )
                    },
                  ),
                ),
              );
            },
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: () => const Center(
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
            ),
          ),
    );
  }
}
