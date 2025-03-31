import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'dart:async'; // Required for StreamSubscription

import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;
import '../bluetooth/bluetooth_service.dart';
import './send_status.dart';
import '../services/location_service.dart';
import '../services/twilio_service.dart';

class ModeSynchronizer {
  final BluetoothService _bluetoothService;
  final SendStatus _sendStatus;

  final StreamController<String> _modeController = StreamController<String>.broadcast();
  String _currentMode = "safe"; // Default mode is safe
  Position? crashDetectedLocation;
  StreamSubscription<Position>? positionStream;

  // Public getter for the mode stream
  Stream<String> get modeStream => _modeController.stream;

  ModeSynchronizer(this._bluetoothService)
      : _sendStatus = SendStatus(_bluetoothService) {
    _setupMessageListener();
  }

  void _setupMessageListener() {
    _bluetoothService.setMessageListener((message) {
      if (message == "safe" || message == "crash") {
        _updateMode(message);
      }
    });
  }

  void _updateMode(String newMode) {
    if (_currentMode != newMode) {
      _currentMode = newMode;
      _modeController.add(newMode); // Notify listeners of the mode change
      print("Mode updated to: $newMode");
    }
  }

  void setMode(String mode) {
    if (mode == "safe" || mode == "crash") {
      _sendStatus.sendMode(mode); // Send the mode to the microcontroller
      _updateMode(mode); // Update the local mode
    }
  }

  Future<void> _sendCrashAlert() async {
    try {
      // Request location permissions
      await LocationService.requestLocationPermission();

      // Get the user's current location
      Position position = await LocationService.getCurrentPosition();

      // Store the location and set the flag
      setState(() {
        //// TODO: insert location into firebase
        crashDetectedLocation = position;
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

  Future<void> _sendSafetyConfirmation() async {

    // Stop monitoring location changes
    positionStream?.cancel();

    String safetyMessage = "Safety confirmed";
    await TwilioService.sendSms(safetyMessage);
  }

  void _checkIfUserIsOnTheMove(Position currentPosition) async {
    if (_currentMode == "safe" || crashDetectedLocation == null) return;

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


}