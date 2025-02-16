import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothService {
  final FlutterBluePlus _flutterBlue = FlutterBluePlus();
  BluetoothDevice? _esp32Device;
  BluetoothCharacteristic? _characteristic;
  bool isConnected = false;

  // Callbacks for UI updates
  Function(bool)? onConnectionChanged;
  Function(String)? onDataReceived; // Notify UI about received data

  void scanAndConnect() async {
    _flutterBlue.startScan(timeout: const Duration(seconds: 4));

    _flutterBlue.scanResults.listen((results) async {
      for (ScanResult result in results) {
        if (result.device.name == "ESP32_BLE") {
          _esp32Device = result.device;
          await _esp32Device!.connect();
          isConnected = true;
          onConnectionChanged?.call(true); // Notify UI about connection
          _flutterBlue.stopScan();

          // Discover services and characteristics
          List<BluetoothService> services = await _esp32Device!.discoverServices();
          for (BluetoothService service in services) {
            for (BluetoothCharacteristic char in service.characteristics) {
              if (char.properties.write == true && char.properties.notify == true) {
                _characteristic = char;
                await _characteristic!.setNotifyValue(true);
                _characteristic!.value.listen((value) {
                  String message = String.fromCharCodes(value);
                  onDataReceived?.call(message); // Notify UI about received data
                });
              }
            }
          }
        }
      }
    });
  }

  void toggleLed() async {
    if (_characteristic != null) {
      await _characteristic!.write("TOGGLE_LED".codeUnits);
    }
  }

  void disconnect() async {
    if (_esp32Device != null) {
      await _esp32Device!.disconnect();
      isConnected = false;
      onConnectionChanged?.call(false); // Notify UI about disconnection
    }
  }
}