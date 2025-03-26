import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import './services/device_id_service.dart';
import './bluetooth/bluetooth_service.dart';
import './bluetooth/bluetooth_btn.dart';
import './settings/settings_btn.dart';
import './crash/crash_msg.dart';
import './crash/crash_safe_btns.dart';
import './contacts/emergency_contact_tbl.dart';
import './contacts/add_contact_btn.dart';
import './other/bt_msg_display.dart';
import './crash/mode_synchronizer.dart';
import 'firebase_options.dart';

// Main app code
void main() async {
  // Firebase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Run app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Helmet',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[200],
        useMaterial3: true,
        fontFamily: 'Nunito',
      ),
      home: const MyHomePage(title: 'Smart Helmet'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final BluetoothService _bluetoothService = BluetoothService();
  late final ModeSynchronizer _modeSynchronizer;

  @override
  void initState() {
    super.initState();
    _modeSynchronizer = ModeSynchronizer(_bluetoothService); // Initialize ModeSynchronizer
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[200],
        title: Text(widget.title),
        actions: [
          BluetoothIcon(bluetoothService: _bluetoothService),
          EditSettingsBtn()
        ],
      ),
      body: FutureBuilder<String>(
        future: getOrGenDeviceId(), // Retrieve device ID from the new service
        builder: (context, snapshot) {
          // Getting device ID
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final String deviceId = snapshot.data!;

          // Returning home page
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CrashMsg(deviceId: deviceId),
                CrashSafeBtns(modeSynchronizer: _modeSynchronizer), // Pass ModeSynchronizer
                // MessageDisplay(message: _message),
                EmergencyContactTbl(),
                AddContactBtn(),
              ],
            ),
          );
        },
      ),
    );
  }
}