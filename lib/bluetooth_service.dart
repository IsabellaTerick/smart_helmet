import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class BluetoothService {
  fb.BluetoothDevice? _connectedDevice; // Use fb prefix for flutter_blue_plus classes
  fb.BluetoothCharacteristic? _characteristic;
  final _connectionController = StreamController<bool>.broadcast(); // Track connection state
  bool _isConnected = false;

  // Callback to notify listeners of new messages
  Function(String)? _messageListener;

  // Setter for the message listener
  void setMessageListener(Function(String) listener) {
    _messageListener = listener;
  }

  void _updateConnectionStatus(bool connected) {
    _isConnected = connected;
    _connectionController.add(connected); // Notify listeners
  }

  Future<void> scanAndConnect() async {
    await _requestPermissions(); // Request permissions for Android

    print("Start scanning...");
    fb.FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    fb.FlutterBluePlus.scanResults.listen((results) async {
      for (fb.ScanResult result in results) {
        if (result.advertisementData.advName == "ESP32_BLE") {
          print("Found target device: ESP32_BLE");
          _connectedDevice = result.device;

          try {
            // Connect to the device
            await _connectedDevice!.connect();
            _updateConnectionStatus(true); // Update connection status
            print("Connected to ${_connectedDevice!.platformName}");

            // Discover services
            List<fb.BluetoothService> services = await _connectedDevice!.discoverServices();
            for (var service in services) {
              for (var char in service.characteristics) {
                if (char.uuid.toString() == "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
                  _characteristic = char;

                  // Enable notifications
                  await _characteristic!.setNotifyValue(true);
                  _characteristic!.lastValueStream.listen((value) {
                    final message = String.fromCharCodes(value);
                    _notifyMessageListener(message);
                    print("Received notification: $message");
                  });

                  print("Notifications enabled for characteristic: UUID=${char.uuid}");
                }
              }
            }

            // Stop scanning after connection
            fb.FlutterBluePlus.stopScan();
          } catch (e) {
            _updateConnectionStatus(false); // Reset on failure
            print("Error connecting to device: $e");
          }
        }
      }
    });
  }

  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android &&
        await Permission.location.isDenied) {
      await Permission.location.request();
    }
  }

  void _notifyMessageListener(String message) {
    if (_messageListener != null) {
      _messageListener!(message);
    }
  }

  fb.BluetoothCharacteristic? get characteristic => _characteristic;
}