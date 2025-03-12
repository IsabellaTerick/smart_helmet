import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BLEPage(),
    );
  }
}

class BLEPage extends StatefulWidget {
  @override
  _BLEPageState createState() => _BLEPageState();
}

class _BLEPageState extends State<BLEPage> {
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? characteristic;
  String message = "No message received";

  Future<void> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Request location permissions for Android
      if (await Permission.location.isDenied) {
        await Permission.location.request();
      }
    }
  }

  void scanAndConnect() async {
    await requestPermissions(); // Request permissions for Android

    // Start scanning
    print("Start scanning...");
    FlutterBluePlus.startScan(timeout: Duration(seconds: 10));

    FlutterBluePlus.scanResults.listen((results) async {
      print("Amount of devices found: ${results.length}");
      for (ScanResult result in results) {
        print("Discovered device: Name=${result.advertisementData.advName}, ID=${result.device.remoteId}");

        // Filter for the ESP32_BLE device
        if (result.advertisementData.advName == "ESP32_BLE") {
          print("Found target device: ESP32_BLE");
          connectedDevice = result.device;

          try {
            // Connect to the device
            await connectedDevice!.connect();
            print("Connected to ${connectedDevice!.platformName}");

            // Discover services
            List<BluetoothService> services = await connectedDevice!.discoverServices();
            for (BluetoothService service in services) {
              print("Discovered service: UUID=${service.uuid}");
              for (BluetoothCharacteristic char in service.characteristics) {
                print("Discovered characteristic: UUID=${char.uuid}");

                // Check for the target characteristic
                if (char.uuid.toString() == "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
                  characteristic = char;

                  // Enable notifications
                  await characteristic!.setNotifyValue(true);
                  characteristic!.lastValueStream.listen((value) {
                    setState(() {
                      message = String.fromCharCodes(value);
                    });
                    print("Received notification: $message");
                  });

                  print("Notifications enabled for characteristic: UUID=${char.uuid}");
                }
              }
            }

            // Stop scanning after connection
            FlutterBluePlus.stopScan();
          } catch (e) {
            print("Error connecting to device: $e");
          }
        }
      }
    });
  }

  void toggleLED() async {
    if (characteristic != null) {
      try {
        await characteristic!.write(utf8.encode("Toggle LED"));
        print("Sent 'Toggle LED' command to ESP32");
      } catch (e) {
        print("Error writing to characteristic: $e");
      }
    } else {
      print("Characteristic not found!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ESP32 BLE Communication"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: scanAndConnect,
              child: Text("Connect to ESP32"),
            ),
            SizedBox(height: 20),
            Text("Message: $message", style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: toggleLED,
              child: Text("Toggle LED"),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:convert';
// import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: BLEPage(),
//     );
//   }
// }
//
// class BLEPage extends StatefulWidget {
//   @override
//   _BLEPageState createState() => _BLEPageState();
// }
//
// class _BLEPageState extends State<BLEPage> {
//   BluetoothDevice? connectedDevice;
//   BluetoothCharacteristic? characteristic;
//   String message = "No message received";
//
//   Future<void> requestPermissions() async {
//     if (defaultTargetPlatform == TargetPlatform.android) {
//       // Request location permissions for Android
//       if (await Permission.location.isDenied) {
//         await Permission.location.request();
//       }
//     }
//   }
//
//   void scanAndConnect() async {
//     await requestPermissions(); // Request permissions for Android
//
//     // Start scanning
//     print("Start scanning...");
//     FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
//
//     FlutterBluePlus.scanResults.listen((results) async {
//       print("Amount of devices found: ${results.length}");
//       for (ScanResult result in results) {
//         print("Discovered device: Name=${result.advertisementData.localName}, ID=${result.device.remoteId}");
//
//         // Filter for the ESP32_BLE device
//         if (result.advertisementData.localName == "ESP32_BLE") {
//           print("Found target device: ESP32_BLE");
//           connectedDevice = result.device;
//
//           try {
//             // Connect to the device
//             await connectedDevice!.connect();
//             print("Connected to ${connectedDevice!.platformName}");
//
//             // Discover services
//             List<BluetoothService> services = await connectedDevice!.discoverServices();
//             for (BluetoothService service in services) {
//               print("Discovered service: UUID=${service.uuid}");
//               for (BluetoothCharacteristic char in service.characteristics) {
//                 print("Discovered characteristic: UUID=${char.uuid}");
//
//                 // Check for the target characteristic
//                 if (char.uuid.toString() == "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
//                   characteristic = char;
//
//                   // Enable notifications
//                   await characteristic!.setNotifyValue(true);
//                   characteristic!.lastValueStream.listen((value) {
//                     setState(() {
//                       message = String.fromCharCodes(value);
//                     });
//                     print("Received notification: $message");
//                   });
//
//                   print("Notifications enabled for characteristic: UUID=${char.uuid}");
//                 }
//               }
//             }
//
//             // Stop scanning after connection
//             FlutterBluePlus.stopScan();
//           } catch (e) {
//             print("Error connecting to device: $e");
//           }
//         }
//       }
//     });
//   }
//
//   void toggleLED() async {
//     if (characteristic != null) {
//       try {
//         await characteristic!.write(utf8.encode("Toggle LED"));
//         print("Sent 'Toggle LED' command to ESP32");
//       } catch (e) {
//         print("Error writing to characteristic: $e");
//       }
//     } else {
//       print("Characteristic not found!");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("ESP32 BLE Communication"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: scanAndConnect,
//               child: Text("Connect to ESP32"),
//             ),
//             SizedBox(height: 20),
//             Text("Message: $message", style: TextStyle(fontSize: 20)),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: toggleLED,
//               child: Text("Toggle LED"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }