import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../bluetooth/bluetooth_service.dart';
import '../services/device_id_service.dart';
import '../services/firebase_service.dart';
import '../services/location_service.dart';
import '../services/twilio_service.dart';
import './send_status.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModeSynchronizer {
  final BluetoothService _bluetoothService;
  final SendStatus _sendStatus;

  final StreamController<String> _modeController = StreamController<String>.broadcast();
  String _currentMode = "safe"; // Default mode is safe
  Position? crashDetectedLocation;
  StreamSubscription<Position>? positionStream;

  // Public getter for the mode stream
  Stream<String> get modeStream => _modeController.stream;

  FirebaseService firebaseService = FirebaseService();
  TwilioService twilioService = TwilioService();

  ModeSynchronizer(this._bluetoothService)
      : _sendStatus = SendStatus(_bluetoothService) {
    _initializeCurrentMode();
    _setupMessageListener();
  }

  Future<void> _initializeCurrentMode() async {
    // Fetch the current mode from Firestore
    String? mode = await firebaseService.getMode();
    if (mode != null && (mode == "safe" || mode == "crash")) {
      _currentMode = mode;
      _modeController.add(mode); // Notify listeners of the mode change
      print("Initialized current mode from Firestore: $_currentMode");
    } else {
      print("No valid mode found in Firestore. Defaulting to 'safe'.");
    }
  }

  void _setupMessageListener() {
    _bluetoothService.setMessageListener((context, message) {
      if (message == "safe" || message == "crash") {
        if (message != _currentMode) { // Prevent feedback loop
          setMode(context, message);
        }
      }
    });
  }

  void _updateMode(String newMode) {
    if (_currentMode != newMode) {
      _currentMode = newMode;
      _modeController.add(newMode); // Notify listeners of the mode change
      print("Mode updated to: $newMode");

      // Update mode in Firestore
      _updateFirestoreMode(newMode);

      // Send the mode to the microcontroller
      _sendStatus.sendMode(newMode);
    }
  }

  void setMode(BuildContext context, String mode) {
    if (mode == "safe" || mode == "crash") {
      print("Setting mode: $mode");
      if (mode != _currentMode) { ////
        _updateMode(mode); // Update the local mode
        if (mode == "crash") {
          _textCrashAlert(context);
        } else if (mode == "safe") {
          _textSafetyConfirmation(context);
        }
      }
    }
  }

  Future<void> _updateFirestoreMode(String newMode) async {
    try {
      String deviceId = await getOrGenDeviceId();
      await FirebaseFirestore.instance
          .collection(deviceId)
          .doc('settings')
          .set({'mode': newMode}, SetOptions(merge: true));
      print("Updated Firestore mode to: $newMode");
    } catch (e) {
      print("Error updating Firestore mode: $e");
    }
  }

  Future<void> _textCrashAlert(BuildContext context) async {
    try {
      // Check if SMS is enabled
      if (!(await _isSMSEnabled())) {
        print("SMS is disabled. Skipping crash alert.");
        return;
      }

      // Request location permissions
      await LocationService.requestLocationPermission();

      // Get the user's current location
      Position position = await LocationService.getCurrentPosition();
      crashDetectedLocation = position;

      // Start monitoring location changes
      positionStream = LocationService.getPositionStream().listen((Position currentPosition) {
        _checkIfUserIsOnTheMove(context, currentPosition);
      });

      // Send the crash SMS
      String googleMapsUrl = "https://maps.google.com/?q=${position.latitude},${position.longitude}";
      twilioService.sendCrashSMS(context, googleMapsUrl);
    } catch (e) {
      print("Error sending crash alert: $e");
    }
  }

  Future<void> _textSafetyConfirmation(BuildContext context) async {
    // Check if SMS is enabled
    if (!(await _isSMSEnabled())) {
      print("SMS is disabled. Skipping safety confirmation.");
      return;
    }

    // Stop monitoring location changes
    positionStream?.cancel();

    // Send the safety confirmation SMS
    twilioService.sendSafeSMS(context);
  }

  void _checkIfUserIsOnTheMove(BuildContext context, Position currentPosition) async {
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
      twilioService.sendUpdateSMS(context, googleMapsUrl);

      // Stop monitoring location changes
      positionStream?.cancel();
    }
  }

  // Helper method to check if SMS is enabled
  Future<bool> _isSMSEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('enableSMS') ?? false; // Default is unchecked (false)
  }
}