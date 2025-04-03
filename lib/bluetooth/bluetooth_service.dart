import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:provider/provider.dart';
import '../services/firebase_service.dart'; // Import FirebaseService
import '../notifications/notification_manager.dart';
import '../crash/send_status.dart'; // Import SendStatus

class BluetoothService {
  fb.BluetoothDevice? _connectedDevice; // Use fb prefix for flutter_blue_plus classes
  fb.BluetoothCharacteristic? _characteristic;
  final StreamController<bool> _connectionController =
  StreamController<bool>.broadcast(); // Track connection state
  final FirebaseService _firebaseService = FirebaseService();
  late final SendStatus _sendStatus; // Instance of SendStatus
  bool _isConnected = false;
  bool _sentMode = false;

  // Public getter for the connection state stream
  Stream<bool> get connectionStateStream => _connectionController.stream;

  // Callback to notify listeners of new messages
  Function(BuildContext, String)? _messageListener;

  // Constructor to initialize SendStatus
  BluetoothService() {
    _sendStatus = SendStatus(this); // Initialize SendStatus with this instance
  }

  // Setter for the message listener
  void setMessageListener(Function(BuildContext, String) listener) {
    _messageListener = listener;
  }

  void _updateConnectionStatus(BuildContext context, bool connected) {
    // Trigger notifications if connection status changed
    final notificationManager = Provider.of<NotificationManager>(context, listen: false);
    if (_isConnected != connected) {
      if (connected) {
        notificationManager.showNotification(
          message: "Smart Helmet connected",
          backgroundColor: Colors.green,
          icon: Icons.bluetooth_connected,
        );
      } else {
        notificationManager.showNotification(
          message: "Smart Helmet disconnected",
          backgroundColor: Colors.red,
          icon: Icons.bluetooth_disabled,
        );
      }
      _isConnected = connected;
      _connectionController.add(connected);
    }
  }

  Future<void> scanAndConnect(BuildContext context) async {
    await _requestPermissions();

    print("Start scanning...");
    fb.FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    bool deviceFound = false;

    fb.FlutterBluePlus.scanResults.listen((results) async {
      for (fb.ScanResult result in results) {
        if (result.advertisementData.advName == "ESP32_BLE") {
          deviceFound = true;
          print("Found target device: ESP32_BLE");
          _connectedDevice = result.device;

          try {
            await _connectedDevice!.connect();
            _updateConnectionStatus(context, true);
            print("Connected to ${_connectedDevice!.platformName}");

            _listenForDisconnection(context);

            List<fb.BluetoothService> services = await _connectedDevice!.discoverServices();
            for (var service in services) {
              for (var char in service.characteristics) {
                if (char.uuid.toString() == "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
                  _characteristic = char;

                  await _characteristic!.setNotifyValue(true);
                  _characteristic!.lastValueStream.listen((value) {
                    final message = String.fromCharCodes(value);
                    _notifyMessageListener(context, message);
                    if (message != '') {
                      print("Received notification: $message");
                    }
                  });

                  // Send initial mode ("crash") to the microcontroller
                  if (_sentMode == false) {
                    await _sendInitialMode(context);
                  }
                }
              }
            }

            fb.FlutterBluePlus.stopScan();
          } catch (e) {
            _updateConnectionStatus(context, false);
            print("Error connecting to device: $e");
          }
        }
      }
    });

    // Stop scanning if no device is found after the timeout
    Future.delayed(const Duration(seconds: 2), () {
      if (!deviceFound) {
        final notificationManager = Provider.of<NotificationManager>(context, listen: false);
        notificationManager.showNotification(
          message: "Smart Helmet not found",
          backgroundColor: Colors.orange,
          icon: Icons.bluetooth_searching,
        );
        fb.FlutterBluePlus.stopScan();
      }
    });
  }

  // Listen for disconnection events
  void _listenForDisconnection(BuildContext context) {
    if (_connectedDevice != null) {
      _connectedDevice!.connectionState.listen((state) {
        if (state == fb.BluetoothConnectionState.disconnected) {
          _updateConnectionStatus(context, false);
          _sentMode = false;
          print("Device disconnected.");
        }
      });
    }
  }

  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android &&
        await Permission.location.isDenied) {
      await Permission.location.request();
    }
  }

  void _notifyMessageListener(BuildContext context, String message) {
    if (_messageListener != null) {
      _messageListener!(context, message);
    }
  }

  // Method to send initial mode ("crash") to the microcontroller
  Future<void> _sendInitialMode(BuildContext context) async {
    try {
      _sentMode = true;
      // Fetch the current mode from Firestore
      String? currentMode = await _firebaseService.getMode();
      print("Firebase mode: $currentMode");
      if (currentMode == "crash") {
        _sendStatus.sendCrash(); // Send "crash" to microcontroller
        print("Sent mode after Bluetooth Connection: Crash");
      }
    } catch (e) {
      print("Failed to send initial mode: $e");
    }
  }

  fb.BluetoothCharacteristic? get characteristic => _characteristic;
}