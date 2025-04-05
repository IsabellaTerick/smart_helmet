import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/device_id_service.dart';
import '../notifications/notification_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void editContactCrashMsgDialog (BuildContext context, String? deviceId, String? contactId, String? name, String? num) {
  //Controllers to edit text box
  TextEditingController msgCtrl = TextEditingController();

  // State for error message
  String? errorMessage;

  // Popup dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Edit Contact Crash Message"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: msgCtrl,
                  decoration: const InputDecoration(labelText: "Custom Crash Message"),
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
                  String customCrashMsg = msgCtrl.text.trim();

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
                        'customCrashMsg': customCrashMsg,
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      // Trigger "Contact edited" notification
                      final notificationManager = Provider.of<NotificationManager>(context, listen: false);
                      notificationManager.showNotification(
                        message: "Contact crash message edited",
                        backgroundColor: Colors.grey,
                        icon: Icons.edit,
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
                child: Text("Save Changes"),
              ),
            ],
          );
        },
      );
    },
  );
}