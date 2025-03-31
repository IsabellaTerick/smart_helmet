import 'package:flutter/material.dart';
import './mode_synchronizer.dart';
import './crash_confirm_popup.dart';

class CrashSafeBtns extends StatefulWidget {
  final ModeSynchronizer modeSynchronizer;

  const CrashSafeBtns({super.key, required this.modeSynchronizer});

  @override
  _CrashSafeBtnsState createState() => _CrashSafeBtnsState();
}

class _CrashSafeBtnsState extends State<CrashSafeBtns> {
  // TODO: GET CURRENT MODE FROM DATABASE
  String _currentMode = "safe";

  @override
  void initState() {
    super.initState();
    widget.modeSynchronizer.modeStream.listen((newMode) {
      setState(() {
        _currentMode = newMode;
      });
    });
  }

  Future<void> _handleCrashButtonPress(BuildContext context) async {
    // Show the confirmation dialog
    bool? userConfirmed = await showCrashConfirmationDialog(context);

    // If the user confirmed, send the crash alert
    if (userConfirmed == true) {
      widget.modeSynchronizer.setMode("crash");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
          top: 10.0, bottom: 10.0, right: 20.0, left: 20.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _currentMode == "safe"
                    ? () => _handleCrashButtonPress(context)
                    : null,
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
              onPressed: _currentMode == "crash"
                  ? () {
                      widget.modeSynchronizer.setMode("safe");
                    }
                  : null,
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
