import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifications/notification_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/device_id_service.dart';

// Method to show the popup for editing the crash message
Future<void> editCrashMessageDialog(BuildContext context, String? deviceId, String? contactId) async {
  // Controller for the crash message text field
  TextEditingController msgCtrl = TextEditingController();

  // State for error message
  String? errorMessage;

  // Fetch the current crash message from Firestore
  String? initialCrashMessage;
  try {
    String currentDeviceId = deviceId ?? await getOrGenDeviceId();
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection(currentDeviceId)
        .doc('contacts')
        .collection('list')
        .doc(contactId)
        .get();

    if (doc.exists && doc.data() != null) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      initialCrashMessage = data?['customCrashMsg']?.toString().trim();
    }
  } catch (e) {
    print("Error fetching initial crash message: $e");
  }

  // Pre-fill the text field with the current crash message
  msgCtrl.text = initialCrashMessage ?? "";

  // Show the dialog and wait for it to close
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Edit Crash Message"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: msgCtrl,
                  decoration: InputDecoration(
                    labelText: "Custom Crash Message",
                    errorText: errorMessage == "Please enter a crash message" ? errorMessage : null,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog without saving
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    // Get device ID if not provided
                    String currentDeviceId = deviceId ?? await getOrGenDeviceId();

                    // Reference to the contacts collection in Firestore
                    CollectionReference contacts = FirebaseFirestore.instance
                        .collection(currentDeviceId)
                        .doc('contacts')
                        .collection('list');

                    if (contactId != null) {
                      // Update the crash message in Firestore
                      await contacts.doc(contactId).update({
                        'customCrashMsg': null,
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      // Trigger "Crash message updated" notification
                      final notificationManager =
                      Provider.of<NotificationManager>(context, listen: false);
                      notificationManager.showNotification(
                        message: "Crash message cleared",
                        backgroundColor: Colors.grey,
                        icon: Icons.message,
                      );
                    }

                    // Close the dialog
                    Navigator.pop(context);
                  } catch (e) {
                    print("Error updating crash message: $e");

                    setState(() {
                      errorMessage = "Failed to update crash message. Please try again.";
                    });
                  }
                },
                child: Text("Clear"),
              ),
              ElevatedButton(
                onPressed: () async {
                  String crashMessage = msgCtrl.text.trim();
                  try {
                    // Get device ID if not provided
                    String currentDeviceId = deviceId ?? await getOrGenDeviceId();

                    // Reference to the contacts collection in Firestore
                    CollectionReference contacts = FirebaseFirestore.instance
                        .collection(currentDeviceId)
                        .doc('contacts')
                        .collection('list');

                    if (contactId != null) {
                      // Update the crash message in Firestore
                      await contacts.doc(contactId).update({
                        'customCrashMsg': crashMessage,
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      // Trigger "Crash message updated" notification
                      final notificationManager =
                      Provider.of<NotificationManager>(context, listen: false);
                      notificationManager.showNotification(
                        message: "Crash message updated",
                        backgroundColor: Colors.grey,
                        icon: Icons.message,
                      );
                    }

                    // Close the dialog
                    Navigator.pop(context);
                  } catch (e) {
                    print("Error updating crash message: $e");

                    setState(() {
                      errorMessage = "Failed to update crash message. Please try again.";
                    });
                  }
                },
                child: Text("Save"),
              ),
            ],
          );
        },
      );
    },
  );
}