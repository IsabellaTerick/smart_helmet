import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../bluetooth/bluetooth_service.dart';
import '../services/device_id_service.dart';
import '../services/firebase_service.dart';
import './send_status.dart';
import '../services/location_service.dart';
import '../services/twilio_service.dart';

class ModeSynchronizer {
  final BluetoothService _bluetoothService;
  final SendStatus _sendStatus;

  FirebaseService firebaseService = FirebaseService();
  TwilioService twilioService = TwilioService();

  final StreamController<String> _modeController = StreamController<String>.broadcast();
  String _currentMode = "safe"; // Default mode is safe

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

  void _updateMode(String newMode) async {
    if (_currentMode != newMode) {
      _currentMode = newMode;
      _modeController.add(newMode); // Notify listeners of the mode change
      print("Mode updated to: $newMode");

      // Get the device ID (assuming you are using it as the document ID)
      String deviceId = await getOrGenDeviceId();

      // Store mode in Firestore under the settings document
      await FirebaseFirestore.instance
          .collection(deviceId)
          .doc('settings')
          .set({'mode': newMode}, SetOptions(merge: true));
    }
  }

  void setMode(String mode) async {
    var msg = '';
    if (mode == "safe" || mode == "crash") {
      _sendStatus.sendMode(mode); // Send the mode to the microcontroller
      _updateMode(mode); // Update the local mode
    }

    if (mode == "crash") {
      _sendCrashAlert();
    } else if (mode == "safe") {
      _sendSafetyConfirmation();
    } else {
      print("Unknown mode set.");
    }
  }

  Future<void> _sendCrashAlert() async {
    try {
      // Request location permissions
      await LocationService.requestLocationPermission();

      // Get the user's current location
      Position position = await LocationService.getCurrentPosition();

      // Store the crash location in LocationService
      LocationService.crashDetectedLocation = position;

      // Start monitoring location changes
      LocationService.startMonitoringLocation((Position currentPosition) {
        _handleUserMovement(currentPosition);
      });

      // Send the crash SMS
      String googleMapsUrl = "https://maps.google.com/?q=${position.latitude},${position.longitude}";
      twilioService.sendCrashSMS(googleMapsUrl);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _sendSafetyConfirmation() async {
    // Stop monitoring location changes
    LocationService.stopMonitoringLocation();

    // Send the safety confirmation SMS
    twilioService.sendSafeSMS();
  }

  void _handleUserMovement(Position currentPosition) async {
    String googleMapsUrl = "https://maps.google.com/?q=${currentPosition.latitude},${currentPosition.longitude}";
    twilioService.sendUpdateSMS(googleMapsUrl);
  }
}