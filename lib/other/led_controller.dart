import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;
import '../bluetooth/bluetooth_service.dart';
import 'dart:convert';

class LEDController {
  final BluetoothService _bluetoothService;

  LEDController(this._bluetoothService);

  void toggleLED() async {
    final fb.BluetoothCharacteristic? characteristic = _bluetoothService.characteristic;
    if (characteristic != null) {
      try {
        await characteristic.write(utf8.encode("Toggle LED"));
        print("Sent LED toggle command");
      } catch (e) {
        print("Failed to toggle LED: $e");
      }
    } else {
      print("Characteristic not available");
    }
  }
}