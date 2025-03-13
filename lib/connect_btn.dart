import 'package:flutter/material.dart';

class ConnectBtn extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isConnected;

  const ConnectBtn({
    Key? key,
    required this.onPressed,
    required this.isConnected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.bluetooth),
      onPressed: onPressed,
      color: isConnected ? Colors.blue: Colors.black45,
    );
    // return ElevatedButton(
    //   onPressed: onPressed,
    //   style: ElevatedButton.styleFrom(
    //     backgroundColor: isConnected ? Colors.blue.shade800 : Colors.lightBlue,
    //     foregroundColor: Colors.white,
    //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    //   ),
    //   child: Text(
    //     isConnected ? "Connected" : "Connect to ESP32",
    //     style: const TextStyle(fontSize: 16),
    //   ),
    // );
  }
}