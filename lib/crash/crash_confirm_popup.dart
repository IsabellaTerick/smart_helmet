import 'package:flutter/material.dart';

// Function to show a confirmation dialog before sending a crash alert
Future<bool> showCrashConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Confirm Crash Alert"),
        content: const Text("Are you sure you want to send a crash alert? "
            "Your emergency contacts will be notified of your crash."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // User canceled
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // User confirmed
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Send", style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  ) ?? false; // Default to false if the dialog is dismissed without a selection
}