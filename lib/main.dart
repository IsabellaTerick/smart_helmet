import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:uuid/uuid.dart';
import './crash_msg.dart';
import './crash_safe_btns.dart';
import './add_contact_btn.dart';
import './emergency_contact_tbl.dart';

//Function to generate a random unique id for each device the app is downloaded on
Future<String> getOrGenDeviceId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? deviceId = prefs.getString('device_id');

  //Generate unique device id if no id found
  if (deviceId == null) {
    var uuid = Uuid();
    deviceId = uuid.v4();
    await prefs.setString('device_id', deviceId);
  }

  //Return device id
  return deviceId;
}

//Main app code
void main() async {
  //Firebase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //Getting device id
  String deviceId = await getOrGenDeviceId();
  print('Device ID: $deviceId');

  //Run app
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
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //List of contacts for current device
  List<Map<String, String>> contacts = [];

  //Method to add a new contact
  void addNewContact(String name, String num) {
    contacts.add({"name": name, "phoneNum": num});
    print("New Contact: $name $num");
  }

  //Method for bluetooth connection
  void bluetoothConnect() {
     print('Bluetooth button pressed');
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[200],
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: () => {}, icon: Icon(Icons.bluetooth), color: Colors.blue),
        ],
      ),
      body: Stack(
        children: <Widget>[
          // Your main content goes here
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CrashMsg(),
                CrashSafeBtns(),
                EmergencyContactTbl(),
                AddContactBtn(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
