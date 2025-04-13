import 'package:flutter/material.dart';

// Function to show a confirmation dialog before sending a crash alert
Future<bool> showSafeConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Safety Confirmation Alert"),
        content: const Text("Your emergency contacts were alerted of your crash. If you no longer need assistance"
            " and don't need them to track your location, would you like to notify them of your safety?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // User canceled
            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // User confirmed
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Yes", style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  ) ?? false; // Default to false if the dialog is dismissed without a selection
}