import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async'; // Required for StreamSubscription
import './location_service.dart';
import './sms_service.dart';


class CrashDetectionScreen extends StatefulWidget {
  @override
  _CrashDetectionScreenState createState() => _CrashDetectionScreenState();
}

class _CrashDetectionScreenState extends State<CrashDetectionScreen> {
  Position? crashDetectedLocation;
  bool isCrashDetected = false; // Flag to track "Crash Detected"
  StreamSubscription<Position>? positionStream;

  Future<void> _sendCrashAlert() async {
    try {
      // Request location permissions
      await LocationService.requestLocationPermission();

      // Get the user's current location
      Position position = await LocationService.getCurrentPosition();

      // Store the location and set the flag
      setState(() {
        crashDetectedLocation = position;
        isCrashDetected = true;
      });

      // Start monitoring location changes
      positionStream = LocationService.getPositionStream().listen((Position currentPosition) {
        _checkIfUserIsOnTheMove(currentPosition);
      });

      // Send the SMS
      String googleMapsUrl = "https://maps.google.com/?q=${position.latitude},${position.longitude}";
      String message = "Crash detected at: $googleMapsUrl";
      await SmsService.sendSms(message);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _sendSafetyConfirmation() async {
    if (!isCrashDetected) {
      print("No crash detected location stored.");
      return;
    }

    // Stop monitoring location changes
    positionStream?.cancel();

    // Get the user's current location
    Position currentPosition = await LocationService.getCurrentPosition();

    // Reset the flag
    setState(() {
      isCrashDetected = false;
    });

    // Send the SMS
    String googleMapsUrl = "https://maps.google.com/?q=${currentPosition.latitude},${currentPosition.longitude}";
    String safetyMessage = "Safety confirmed at: $googleMapsUrl";
    await SmsService.sendSms(safetyMessage);
  }

  void _checkIfUserIsOnTheMove(Position currentPosition) async {
    if (!isCrashDetected || crashDetectedLocation == null) return;

    // Calculate the distance between the crash location and the current location
    double distanceInMeters = LocationService.calculateDistance(
      crashDetectedLocation!.latitude,
      crashDetectedLocation!.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    // Check if the user has moved more than 402 meters (quarter mile)
    if (distanceInMeters > 402) {
      String googleMapsUrl = "https://maps.google.com/?q=${currentPosition.latitude},${currentPosition.longitude}";
      String moveMessage = "User is on the move: $googleMapsUrl";
      await SmsService.sendSms(moveMessage);

      // Stop monitoring location changes
      positionStream?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crash Detection App"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _sendCrashAlert,
              child: Text("Crash Detected"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendSafetyConfirmation,
              child: Text("Safety Confirmed"),
            ),
          ],
        ),
      ),
    );
  }
}