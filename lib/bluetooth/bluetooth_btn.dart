import 'dart:async';

import 'package:flutter/material.dart';
import './bluetooth_service.dart';

class BluetoothIcon extends StatefulWidget {
  final BluetoothService bluetoothService;

  const BluetoothIcon({super.key, required this.bluetoothService});

  @override
  _BluetoothIconState createState() => _BluetoothIconState();
}

class _BluetoothIconState extends State<BluetoothIcon> {
  late StreamSubscription<bool> _connectionSubscription;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();

    // Subscribe to the connection state stream
    _connectionSubscription = widget.bluetoothService.connectionStateStream.listen((connected) {
      setState(() {
        _isConnected = connected;
      });
    });
  }

  @override
  void dispose() {
    _connectionSubscription.cancel(); // Cancel the subscription to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (!_isConnected) {
          await widget.bluetoothService.scanAndConnect(context);
        }
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isConnected ? Colors.blue : Colors.white, // Circle color
          border: Border.all(
            color: _isConnected ? Colors.blue : Colors.transparent, // Optional border
            width: 2,
          ),
        ),
        child: Icon(
          Icons.bluetooth,
          color: _isConnected ? Colors.white : Colors.blue, // Bluetooth icon color
          size: 30,
        ),
      ),
    );
  }
}