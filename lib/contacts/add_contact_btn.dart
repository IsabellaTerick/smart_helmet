import 'package:flutter/material.dart';
import 'add_contact_popup.dart';
import '../services/firebase_service.dart';
import '../crash/mode_synchronizer.dart';

class AddContactBtn extends StatefulWidget {
  final ModeSynchronizer modeSynchronizer;

  const AddContactBtn({super.key, required this.modeSynchronizer});

  @override
  _AddContactBtnState createState() => _AddContactBtnState();
}

class _AddContactBtnState extends State<AddContactBtn> {
  bool _isButtonEnabled = false; // Tracks whether the button is enabled
  String _currentMode = "safe"; // Tracks the current mode
  int _contactCount = 0; // Tracks the number of contacts

  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();

    // Listen for mode changes
    widget.modeSynchronizer.modeStream.listen((newMode) {
      setState(() {
        _currentMode = newMode;
        _updateButtonState();
      });
    });

    // Listen for contact count changes
    _firebaseService.getEmergencyContactCountStream().listen((count) {
      setState(() {
        _contactCount = count;
        _updateButtonState();
      });
    });

    _updateButtonState();
  }

  // Update the button state based on the current mode and contact count
  void _updateButtonState() {
    setState(() {
      print("Contact count: $_contactCount");
      _isButtonEnabled = _currentMode == "safe" && _contactCount < 5;
      print("_isButtonEnabled: $_isButtonEnabled");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isButtonEnabled
                  ? () {
                // Open the add contact dialog
                addContactDialog(context);
              }
                  : null,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: _isButtonEnabled ? Colors.black54 : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Add New Contact +',
                style: TextStyle(fontFamily: 'Nunito', fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}