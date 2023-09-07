import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geofencing_demo/location_provider.dart';
import 'package:location/location.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ref.watch(locationDataFutureProvider).when(
            data: (data) {
              return Center(child: Text(data!.longitude.toString()));
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
