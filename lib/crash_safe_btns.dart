import 'package:flutter/material.dart';

class CrashSafeBtns extends StatelessWidget {
  const CrashSafeBtns({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ElevatedButton(onPressed: null, child: Text('CRASH ALERT')),
          ElevatedButton(onPressed: null, child: Text('SAFE ALERT'))
        ]
      )
    );
  }
}
