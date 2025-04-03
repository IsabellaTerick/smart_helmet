import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifications/notification_manager.dart'; // Import NotificationManager
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/device_id_service.dart';

// Helper function to normalize and validate phone number
String? normalizeAndValidatePhoneNumber(String phoneNumber) {
  // Remove all non-numeric characters from the input
  String numericOnly = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

  // Check if the cleaned number has exactly 10 digits
  if (numericOnly.length == 10) {
    return '(${numericOnly.substring(0, 3)})-${numericOnly.substring(3, 6)}-${numericOnly.substring(6, 10)}';
  }
  return null; // Return null if the phone number is invalid
}

// Method to show the popup for adding or editing a contact
void addContactDialog(BuildContext context,
    {String? initialName, String? initialPhoneNumber, String? contactId, String? deviceId}) {
  // Controllers for text fields
  TextEditingController nameCtrl = TextEditingController(text: initialName);
  TextEditingController numCtrl = TextEditingController(text: initialPhoneNumber);

  // State for error message
  String? errorMessage;

  // Popup dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(contactId != null ? "Edit Contact" : "Add New Contact"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: numCtrl,
                  decoration: const InputDecoration(labelText: "Phone Number"),
                  keyboardType: TextInputType.phone,
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    errorMessage!,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  String name = nameCtrl.text.trim();
                  String num = numCtrl.text.trim();

                  // Validate phone number
                  String? formattedNumber = normalizeAndValidatePhoneNumber(num);
                  if (name.isEmpty || formattedNumber == null) {
                    setState(() {
                      errorMessage =
                      name.isEmpty ? "Please enter a name" : "Please enter a valid 10-digit phone number";
                    });
                    return;
                  }

                  try {
                    setState(() {
                      errorMessage = null;
                    });

                    // Get device ID if not provided (for new contacts)
                    String currentDeviceId = deviceId ?? await getOrGenDeviceId();

                    // Reference to the contacts collection in Firestore
                    CollectionReference contacts = FirebaseFirestore.instance
                        .collection(currentDeviceId)
                        .doc('contacts')
                        .collection('list');

                    if (contactId != null) {
                      // Update existing contact
                      await contacts.doc(contactId).update({
                        'name': name,
                        'phoneNumber': formattedNumber,
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      // Trigger "Contact edited" notification
                      final notificationManager = Provider.of<NotificationManager>(context, listen: false);
                      notificationManager.showNotification(
                        message: "Contact edited",
                        backgroundColor: Colors.grey,
                        icon: Icons.edit,
                      );
                    } else {
                      // Add new contact
                      await contacts.add({
                        'name': name,
                        'phoneNumber': formattedNumber,
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      // Trigger "Contact added" notification
                      final notificationManager = Provider.of<NotificationManager>(context, listen: false);
                      notificationManager.showNotification(
                        message: "Contact added",
                        backgroundColor: Colors.green,
                        icon: Icons.person_add,
                      );
                    }

                    // Close the dialog
                    Navigator.pop(context);
                  } catch (e) {
                    print("Error saving contact: $e");

                    setState(() {
                      errorMessage = "Failed to save contact. Please try again.";
                    });
                  }
                },
                child: Text(contactId != null ? "Save Changes" : "Save"),
              ),
            ],
          );
        },
      );
    },
  );
}