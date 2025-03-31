import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;
import '../bluetooth/bluetooth_service.dart';
import '../services/device_id_service.dart';
import '../services/twilio_service.dart';
import '../services/firebase_service.dart';
import './send_status.dart';

class ModeSynchronizer {
  final BluetoothService _bluetoothService;
  final SendStatus _sendStatus;

  //Twilio SMS
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
    String? crashMsg = await firebaseService.getCrashMsg();
    String? userName = await firebaseService.getUserName();
    List<String?>? phoneNums = await firebaseService.getEmergencyContactNumbers();
    List<String> contacts = (phoneNums ?? []) as List<String>;

    var msg = '';
    if (mode == "safe" || mode == "crash") {
      _sendStatus.sendMode(mode); // Send the mode to the microcontroller
      _updateMode(mode); // Update the local mode
    }

    //Iterate through list of emergency contacts
    if (phoneNums != null && contacts.isNotEmpty) {
      for (String phoneNum in contacts) {
        //Send out safe message
        if (mode == "safe") {
          msg = 'Alert from Smart Helmet: ${userName ?? "Unknown User"} has confirmed they are safe. No further action needed at this time.';
          twilioService.sendSMS(phoneNum, msg);
        }
        //Send out crash message
        else if (mode == "crash") {
          msg = 'Alert from Smart Helmet: ${userName ?? "Unknown User"} has been involved in a crash. Please check on them and contact emergency. "${crashMsg ?? ""}"';
          twilioService.sendSMS(phoneNum, msg);
        } else {
          print("Unknown mode set.");
        }
      }
    }
  }

  void sendMode(String mode) {
    if (mode == "crash") {
      _sendStatus.sendCrash();
    } else if (mode == "safe") {
      _sendStatus.sendSafe();
    }
    else {
      print("Unknown mode send: $mode");
    }
  }
}