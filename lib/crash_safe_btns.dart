import 'package:flutter/material.dart';

class CrashSafeBtns extends StatelessWidget {

  final VoidCallback onPressed;

  const CrashSafeBtns({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ElevatedButton(onPressed: onPressed, child: Text('CRASH ALERT!')),
          ElevatedButton(onPressed: onPressed, child: Text('SAFE ALERT'))
        ]
      )
    );
  }
}
