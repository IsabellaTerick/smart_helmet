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
    // Show confirmation dialog before sending crash alert
    bool? userConfirmed = await showCrashConfirmationDialog(context);

    if (userConfirmed == true) {
      widget.modeSynchronizer.setMode(context, "crash");
    }
  }

  Future<void> _handleSafeButtonPress(BuildContext context) async {
    widget.modeSynchronizer.setMode(context, "safe");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                  ? () => _handleSafeButtonPress(context)
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