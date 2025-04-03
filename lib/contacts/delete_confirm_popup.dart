import 'package:flutter/material.dart';

// Function to show a confirmation dialog before deleting a contact
Future<bool?> showDeleteConfirmationDialog(BuildContext context, String contactName) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Confirm Deletion"),
        content: Text("Are you sure you want to delete $contactName as a contact?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false); // Cancel deletion
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true); // Confirm deletion
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}