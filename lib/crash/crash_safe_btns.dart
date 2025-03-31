import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async'; // Required for StreamSubscription
import '../services/location_service.dart';
import './mode_synchronizer.dart';
import './crash_confirm_popup.dart';

class CrashSafeBtns extends StatefulWidget {
  final ModeSynchronizer modeSynchronizer;

  const CrashSafeBtns({super.key, required this.modeSynchronizer});

  @override
  _CrashSafeBtnsState createState() => _CrashSafeBtnsState();
}

class _CrashSafeBtnsState extends State<CrashSafeBtns> {
  // TODO: GET CURRENT MODE FROM DATABASE
  String _currentMode = "safe";
  Position? crashDetectedLocation;
  bool isCrashDetected = false; // Flag to track "Crash Detected"
  StreamSubscription<Position>? positionStream;

  @override
  void initState() {
    super.initState();
    widget.modeSynchronizer.modeStream.listen((newMode) {
      setState(() {
        _currentMode = newMode;
      });
    });
  }

  Future<void> _handleCrashButtonPress(BuildContext context) async {

    try {
      // Show the confirmation dialog
      bool? userConfirmed = await showCrashConfirmationDialog(context);

      // If the user confirmed, send the crash alert
      if (userConfirmed == false) {
        return;
      }

      widget.modeSynchronizer.setMode("crash");

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
      await TwilioService.sendSms(message);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _handleSafeButtonPress() async {
    widget.modeSynchronizer.setMode("safe");

    // Stop monitoring location changes
    positionStream?.cancel();

    // Send the SMS
    String safetyMessage = "Safety confirmed.";
    await TwilioService.sendSms(safetyMessage);
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
      await TwilioService.sendSms(moveMessage);

      // Stop monitoring location changes
      positionStream?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
          top: 10.0, bottom: 10.0, right: 20.0, left: 20.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _currentMode == "safe"
                    ? () => _handleCrashButtonPress(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  foregroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'CRASH ALERT!',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _currentMode == "crash"
                  ? () => _handleSafeButtonPress()
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen[700],
                foregroundColor: Colors.white70,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'SAFE ALERT!',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
