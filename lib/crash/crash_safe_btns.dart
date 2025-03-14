import 'package:flutter/material.dart';

class CrashSafeBtns extends StatefulWidget {
  final VoidCallback toggleLED;

  const CrashSafeBtns({super.key, required this.toggleLED});

  @override
  _CrashSafeBtnsState createState() => _CrashSafeBtnsState();
}

class _CrashSafeBtnsState extends State<CrashSafeBtns> {
  bool safe = true;

  void setCrash() {
    setState(() {
      safe = false;
    });
  }

  void setSafe() {
    setState(() {
      safe = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 20.0, left: 20.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: safe ? () { setCrash(); } : null, // Disable the button when safe is false
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  foregroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'CRASH ALERT!',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: !safe ? () { setSafe(); } : null, // Disable the button when safe is true
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen[700],
                foregroundColor: Colors.white70,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'SAFE ALERT!',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}