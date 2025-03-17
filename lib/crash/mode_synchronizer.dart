import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;
import '../bluetooth/bluetooth_service.dart';
import './send_status.dart';

class ModeSynchronizer {
  final BluetoothService _bluetoothService;
  final SendStatus _sendStatus;

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