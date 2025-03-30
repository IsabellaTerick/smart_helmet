import 'package:flutter/material.dart';
import './crash_detection_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Crash Detection App",
      home: CrashDetectionScreen(),
    );
  }
}