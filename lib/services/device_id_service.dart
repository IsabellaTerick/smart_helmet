import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// Function to generate or retrieve a unique device ID
Future<String> getOrGenDeviceId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? deviceId = prefs.getString('device_id');

  // Generate unique device ID if no ID is found
  if (deviceId == null) {
    var uuid = const Uuid();
    deviceId = uuid.v4();
    await prefs.setString('device_id', deviceId);
  }

  print("Device ID: $deviceId");
  return deviceId;
}