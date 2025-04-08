import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import './services/device_id_service.dart';
import './bluetooth/bluetooth_service.dart';
import './bluetooth/bluetooth_btn.dart';
import './settings/settings_btn.dart';
import './help/help_btn.dart';
import './crash/crash_msg.dart';
import './crash/crash_safe_btns.dart';
import './contacts/emergency_contact_tbl.dart';
import './contacts/add_contact_btn.dart';
import './other/bt_msg_display.dart';
import './crash/mode_synchronizer.dart';
import './notifications/notification_manager.dart';
import './notifications/notification_banner.dart';
import './settings/edit_settings_popup.dart';
import './services/firebase_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => NotificationManager(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Helmet',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[200],
        useMaterial3: true,
        fontFamily: 'Nunito',
      ),
      home: Builder(
        builder: (context) => Stack(
          children: [
            const MyHomePage(title: 'Smart Helmet'),
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Consumer<NotificationManager>(
                builder: (context, notificationManager, _) {
                  if (!notificationManager.isVisible) return const SizedBox.shrink();
                  return NotificationBanner(
                    message: notificationManager.message,
                    backgroundColor: notificationManager.backgroundColor,
                    icon: notificationManager.icon,
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _modeSynchronizer = ModeSynchronizer(_bluetoothService);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _bluetoothService.scanAndConnect(context);

      String? userName = await _firebaseService.getUserName();
      print("Username: ${userName}");
      if (userName == null || userName.isEmpty) {
        editUserSettings(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade200,
        title: Text(widget.title),
        actions: [
          BluetoothIcon(bluetoothService: _bluetoothService),
          HelpBtn(),
          EditSettingsBtn(),
        ],
      ),
      body: FutureBuilder<String>(
        future: getOrGenDeviceId(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final String deviceId = snapshot.data!;

          // Use SafeArea and LayoutBuilder to ensure content works across device sizes
          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const SizedBox(height: 10),
                          // Crash message section
                          CrashMsg(deviceId: deviceId),
                          const SizedBox(height: 0),

                          // Crash/Safe buttons
                          CrashSafeBtns(modeSynchronizer: _modeSynchronizer),
                          const SizedBox(height: 0),

                          // Emergency contacts table - no longer in a scrollable container
                          EmergencyContactTbl(modeSynchronizer: _modeSynchronizer),
                          const SizedBox(height: 5),

                          // Add contact button
                          AddContactBtn(modeSynchronizer: _modeSynchronizer),

                          // Add padding at the bottom for better scrolling experience
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}