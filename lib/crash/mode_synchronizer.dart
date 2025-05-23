import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../bluetooth/bluetooth_service.dart';
import '../services/firebase_service.dart';
import '../services/location_service.dart';
import '../services/twilio_service.dart';
import './send_status.dart';
import './safe_confirm_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModeSynchronizer {
  final BluetoothService _bluetoothService;
  final SendStatus _sendStatus;

  final StreamController<String> _modeController =
  StreamController<String>.broadcast();
  String _currentMode = "safe"; // Default mode is safe
  Position? crashDetectedLocation;
  StreamSubscription<Position>? positionStream;
  bool _initialCheckDone = false;

  // Add a Completer to track initialization
  final Completer<void> _initCompleter = Completer<void>();
  Future<void> get initialized => _initCompleter.future;

  // Public getter for the mode stream
  Stream<String> get modeStream => _modeController.stream;
  // Public getter for current mode
  String get currentMode => _currentMode;

  FirebaseService firebaseService = FirebaseService();
  TwilioService twilioService = TwilioService();

  ModeSynchronizer(this._bluetoothService)
      : _sendStatus = SendStatus(_bluetoothService) {
    _initializeCurrentMode();
    _setupMessageListener();
    _initializeCrashLocation();
  }

  void _setupMessageListener() {
    _bluetoothService.setMessageListener((context, message) async {
      if (message == "safe" || message == "crash") {
        // Check if the received mode is different from the current mode
        if (message != _currentMode) {
          print("Received new mode from Bluetooth: $message");
          setMode(context, message);
        } else {
          print("Ignoring duplicate mode update: $message");
        }
      }
    });
  }

  Future<void> _initializeCurrentMode() async {
    try {
      // Fetch the current mode from Firestore
      String? mode = await firebaseService.getMode();
      if (mode != null && (mode == "safe" || mode == "crash")) {
        _currentMode = mode;
        _modeController.add(mode); // Notify listeners of the mode change
        print("Initialized current mode from Firestore: $_currentMode");
      } else {
        print("No valid mode found in Firestore. Defaulting to 'safe'.");
      }
    } catch (e) {
      print("Error initializing current mode: $e");
    } finally {
      // Complete the initialization regardless of success or failure
      _initCompleter.complete();
    }
  }

  Future<void> _initializeCrashLocation() async {
    try {
      // Fetch the crash location from Firestore
      var geoPoint = await firebaseService.getCrashLocation();

      if (geoPoint != null) {
        crashDetectedLocation = Position(
          latitude: geoPoint.latitude,
          longitude: geoPoint.longitude,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );

        print("Crash location loaded into crashDetectedLocation.");
      } else {
        print("No crash location data found.");
      }
    } catch (e) {
      print("Error initializing crashDetectedLocation: $e");
    }
  }

  // Call this method from the main page after build is complete
  Future<void> handleCrashInitialization(BuildContext context) async {
    if (_initialCheckDone) return;

    // Wait for initialization to complete before proceeding
    await initialized;

    _initialCheckDone = true;

    if (_currentMode == "crash") {
      // Show safe confirmation dialog if we're in crash mode
      print("Initial mode is crash, showing safe confirmation dialog");

      // Use Future.delayed to ensure this runs after the current build cycle
      Future.delayed(Duration.zero, () async {
        // Show the dialog and get the result
        bool changeModeToSafe = await showSafeConfirmationDialog(context);

        // If user confirmed, set mode to safe
        if (changeModeToSafe) {
          print("User confirmed safety, changing mode to safe");
          setMode(context, "safe");
        } else {
          print("User canceled safety confirmation,"
              " staying in crash mode and tracking location");
          // Start monitoring location changes
          if (crashDetectedLocation != null) {
            positionStream = LocationService.getPositionStream()
                .listen((Position currentPosition) {
              _checkIfUserIsOnTheMove(context, currentPosition);
            });
          }
        }
      });
    }
  }

  void _updateMode(String newMode) {
    if (_currentMode != newMode) {
      _currentMode = newMode;
      _modeController.add(newMode); // Notify listeners of the mode change
      print("Mode updated to: $newMode");

      // Update mode in Firestore
      firebaseService.updateMode(newMode);

      // Send the mode to the microcontroller
      _sendStatus.sendMode(newMode);
    }
  }

  void setMode(BuildContext context, String mode) {
    if (mode == "safe" || mode == "crash") {
      print("Setting mode: $mode");
      if (mode != _currentMode) {
        _updateMode(mode); // Update the local mode
        if (mode == "crash") {
          _textCrashAlert(context);
        } else if (mode == "safe") {
          _textSafetyConfirmation(context);
        }
      }
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

      // Storing initial crash position into Firestore
      await firebaseService.saveCrashLocation(position.latitude, position.longitude);

      // Start monitoring location changes
      positionStream = LocationService.getPositionStream()
          .listen((Position currentPosition) {
        _checkIfUserIsOnTheMove(context, currentPosition);
      });

      // Send the crash SMS
      String googleMapsUrl =
          "https://maps.google.com/?q=${position.latitude},${position.longitude}";
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

    // Clear crash location from Firebase
    await firebaseService.clearCrashLocation();

    // Clear local crash location
    crashDetectedLocation = null;

    // Stop monitoring location changes
    await positionStream?.cancel();

    // Send the safety confirmation SMS
    twilioService.sendSafeSMS(context);
  }

  void _checkIfUserIsOnTheMove(
      BuildContext context, Position currentPosition) async {
    if (_currentMode == "safe" ||
        crashDetectedLocation == null) {
      return;
    }

    // Calculate the distance between the crash location and the current location
    double distanceInMeters = LocationService.calculateDistance(
      crashDetectedLocation!.latitude,
      crashDetectedLocation!.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    // Check if the user has moved more than 402 meters (quarter mile)
    if (distanceInMeters > 402) {
      print("User has moved more than 402 meters from crash location. Sending update SMS.");

      // Send the update SMS with current location
      String googleMapsUrl =
          "https://maps.google.com/?q=${currentPosition.latitude},${currentPosition.longitude}";
      twilioService.sendUpdateSMS(context, googleMapsUrl);

      // Clear crash location from Firebase
      crashDetectedLocation = null;
      await firebaseService.clearCrashLocation();
      await positionStream?.cancel();
    }
  }

  // Helper method to check if SMS is enabled
  Future<bool> _isSMSEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('enableSMS') ?? false; // Default is unchecked (false)
  }
}