import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import './device_screen.dart'; // Import the DeviceScreen file

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  @override
  void initState() {
    super.initState();
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      if (mounted) setState(() {});
    }, onError: (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Scan Error: $e"), backgroundColor: Colors.red),
      );
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  Future<void> onScanPressed() async {
    try {
      var withServices = [Guid("4fafc201-1fb5-459e-8fcc-c5c9c331914b")]; // ESP32 service UUID
      await FlutterBluePlus.startScan(withServices: withServices, timeout: const Duration(seconds: 15));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Start Scan Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> onStopPressed() async {
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Stop Scan Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void onConnectPressed(BluetoothDevice device) {
    device.connect().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connected to ${device.name}"), backgroundColor: Colors.green),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => DeviceScreen(device: device)),
      );
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connect Error: $e"), backgroundColor: Colors.red),
      );
    });
  }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    return _scanResults
        .where((r) => r.device.name == "ESP32_BLE") // Filter by ESP32 name
        .map(
          (r) => ListTile(
        title: Text(r.device.name),
        subtitle: Text(r.device.id.toString()),
        onTap: () => onConnectPressed(r.device),
      ),
    )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find ESP32')),
      body: ListView(children: _buildScanResultTiles(context)),
      floatingActionButton: FloatingActionButton(
        child: _isScanning ? const Icon(Icons.stop) : const Text("SCAN"),
        onPressed: _isScanning ? onStopPressed : onScanPressed,
      ),
    );
  }
}