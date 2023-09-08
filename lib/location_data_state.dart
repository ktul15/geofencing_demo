import 'package:location/location.dart';

class LocationDataState {
  final LocationData? locationData;
  final bool isLoading;
  final String error;

  LocationDataState(
      {required this.locationData,
      required this.isLoading,
      required this.error});

  LocationDataState copyWith({
    LocationData? locationData,
    bool? isLoading,
    String? error,
  }) {
    print("locationData from: $locationData");
    return LocationDataState(
        locationData: locationData ?? this.locationData,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error);
  }
}

// class LocationDataProgress extends LocationDataState {}
