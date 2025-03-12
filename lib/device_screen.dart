import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  bool _isConnected = false;
  BluetoothCharacteristic? _characteristic;
  String _receivedData = "No data received yet";

  @override
  void initState() {
    super.initState();
    connectToDevice();
  }

  /// Connect to the BLE device and discover services
  Future<void> connectToDevice() async {
    try {
      await widget.device.connect();
      setState(() {
        _isConnected = true;
      });
      discoverServices();
    } catch (e) {
      print("Connection Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to connect: $e"), backgroundColor: Colors.red),
      );
    }
  }

  /// Discover services and characteristics of the BLE device
  Future<void> discoverServices() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid.toString() == "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
          setState(() {
            _characteristic = characteristic;
          });

          // Enable notifications for the characteristic
          await characteristic.setNotifyValue(true);
          characteristic.value.listen((value) {
            setState(() {
              _receivedData = String.fromCharCodes(value); // Update received data
            });
          });
        }
      }
    }
  }

  /// Toggle the LED on the ESP32
  Future<void> toggleLed() async {
    if (_characteristic != null) {
      try {
        await _characteristic!.write("TOGGLE_LED".codeUnits);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("LED toggled!"), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to toggle LED: $e"), backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Characteristic not found!"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name ?? "Unnamed Device"),
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled),
            onPressed: () {
              if (!_isConnected) {
                connectToDevice();
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Connected to: ${widget.device.id}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: toggleLed,
              child: Text("Toggle LED"),
            ),
            SizedBox(height: 20),
            Text(
              "Received Data: $_receivedData",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.device.disconnect(); // Disconnect when leaving the screen
    super.dispose();
  }
}