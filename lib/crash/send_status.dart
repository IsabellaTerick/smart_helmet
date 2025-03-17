import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;
import '../bluetooth/bluetooth_service.dart';
import 'dart:convert';

// Class responsible for sending mode updates to the microcontroller
class SendStatus {
  final BluetoothService _bluetoothService;

  // Constructor to initialize with a BluetoothService instance
  SendStatus(this._bluetoothService);

  // Method to send "crash" mode to the microcontroller
  Future<void> sendCrash() async {
    await _sendMessage("crash");
  }

  // Method to send "safe" mode to the microcontroller
  Future<void> sendSafe() async {
    await _sendMessage("safe");
  }

  // Method to send current mode to the microcontroller
  Future<void> sendMode(String mode) async {
    await _sendMessage(mode);
  }

  // Generic method to send a message to the microcontroller
  Future<void> _sendMessage(String message) async {
    final fb.BluetoothCharacteristic? characteristic = _bluetoothService.characteristic;
    if (characteristic != null) {
      try {
        await characteristic.write(utf8.encode(message));
        print("Sent message: $message");
      } catch (e) {
        print("Failed to send mode update: $e");
      }
    } else {
      print("Characteristic not available");
    }
  }
}