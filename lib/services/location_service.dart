import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Position? crashDetectedLocation; // Store the crash location here
  static StreamSubscription<Position>? positionStream;

  static Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return true;
  }

  static Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  static double calculateDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
  }

  static void startMonitoringLocation(void Function(Position) onUserMoves) {
    positionStream = getPositionStream().listen((Position currentPosition) {
      if (crashDetectedLocation != null) {
        double distanceInMeters = calculateDistance(
          crashDetectedLocation!.latitude,
          crashDetectedLocation!.longitude,
          currentPosition.latitude,
          currentPosition.longitude,
        );

        if (distanceInMeters > 402) {
          onUserMoves(currentPosition); // Notify when the user moves more than 402 meters
          stopMonitoringLocation(); // Stop monitoring after detecting movement
        }
      }
    });
  }

  static void stopMonitoringLocation() {
    positionStream?.cancel();
    crashDetectedLocation = null; // Reset crash location
  }
}